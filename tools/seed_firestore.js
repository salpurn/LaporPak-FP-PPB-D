/**
 * Firestore Ticket Seeder — LaporPak
 *
 * Prerequisites:
 *   1. npm install firebase-admin
 *   2. Download service account key:
 *      Firebase Console → Project Settings → Service Accounts → Generate new private key
 *      Save the file as:  tools/serviceAccountKey.json
 *   3. node tools/seed_firestore.js
 */

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

// ─── User constants (from Firestore users collection) ────────────────────────

const WORKER = {
  uid: '5s39WAfJHZYkxShNjPNNi8KDxS03',
  workerId: 'ID146',          // AppUser.workerId — used as Ticket.workerId
  name: 'Sal Purnama',
  department: 'sukolilo',
};

const SUPERVISOR = {
  uid: 'QGGtk3G6OOUA1sx51H7rm02xHYU2',
  name: 'Farhan',
  department: 'sukolilo',
};

const MAINTENANCE = {
  uid: 'J7p35IDXBrMNSEXpHSxTqhEYA2o1',
  name: 'Atal',
  department: 'sukolilo',
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

function daysAgo(n) {
  const d = new Date();
  d.setDate(d.getDate() - n);
  return d.toISOString();
}

function daysFromNow(n) {
  const d = new Date();
  d.setDate(d.getDate() + n);
  return d.toISOString();
}

function newId() {
  return db.collection('tickets').doc().id;
}

function base({ id, title, location, description, category, urgency, daysAgoCreated = 1 }) {
  const ts = daysAgo(daysAgoCreated);
  return {
    id,
    title,
    location,
    description,
    category,
    urgency,
    department: WORKER.department,
    workerId: WORKER.workerId,
    workerName: WORKER.name,
    workerDepartment: WORKER.department,
    assigneeId: null,
    supervisorId: null,
    deadline: null,
    createdAt: ts,
    updatedAt: ts,
    resolutionReport: null,
    photoUrl: '',
  };
}

// ─── Seed data ────────────────────────────────────────────────────────────────

const tickets = [

  // open
  {
    ...base({
      id: newId(),
      title: 'Leaking pipe in Corridor B',
      location: 'Corridor B, Ground Floor',
      description: 'Water dripping from an overhead pipe near the fire exit. Floor is wet and poses a slip hazard.',
      category: 'structural',
      urgency: 'high',
      daysAgoCreated: 3,
    }),
    status: 'open',
  },

  // open
  {
    ...base({
      id: newId(),
      title: 'Exposed wiring in panel room',
      location: 'Electrical Panel Room, Basement',
      description: 'Insulation worn off on two cables near the main breaker. Risk of short circuit or electrocution.',
      category: 'electrical',
      urgency: 'critical',
      daysAgoCreated: 1,
    }),
    status: 'open',
  },

  // assigned
  {
    ...base({
      id: newId(),
      title: 'Oil spill on factory floor',
      location: 'Machine Room 2',
      description: 'Hydraulic oil leak from Machine 07. Oil has spread across a 3m² area. Machines nearby are still running.',
      category: 'chemical',
      urgency: 'high',
      daysAgoCreated: 4,
    }),
    status: 'assigned',
    assigneeId: MAINTENANCE.uid,
    supervisorId: SUPERVISOR.uid,
    deadline: daysFromNow(3),
    updatedAt: daysAgo(3),
  },

  // pendingValidation
  {
    ...base({
      id: newId(),
      title: 'Blocked emergency exit — storeroom',
      location: 'Storeroom C, Ground Floor',
      description: 'Emergency exit door blocked by stacked pallets. Door cannot be opened from the inside.',
      category: 'structural',
      urgency: 'critical',
      daysAgoCreated: 7,
    }),
    status: 'pendingValidation',
    assigneeId: MAINTENANCE.uid,
    supervisorId: SUPERVISOR.uid,
    deadline: daysAgo(1),
    updatedAt: daysAgo(1),
    resolutionReport: {
      completionNote: 'All pallets relocated to the designated storage zone. Emergency exit door tested — opens freely. Floor area marked with yellow safety tape.',
      photoUrl: '',
      submittedBy: MAINTENANCE.uid,
      submittedAt: daysAgo(1),
    },
  },

  // rejected
  {
    ...base({
      id: newId(),
      title: 'Flickering lights in warehouse',
      location: 'Warehouse Section D',
      description: 'Lights flickering on and off. Reported by three workers on the night shift.',
      category: 'electrical',
      urgency: 'medium',
      daysAgoCreated: 5,
    }),
    status: 'rejected',
    assigneeId: MAINTENANCE.uid,
    supervisorId: SUPERVISOR.uid,
    deadline: daysAgo(2),
    updatedAt: daysAgo(2),
    resolutionReport: {
      completionNote: 'Checked the lights. Seems fine now.',
      photoUrl: '',
      submittedBy: MAINTENANCE.uid,
      submittedAt: daysAgo(2),
    },
  },

];

// ─── Run seeder ───────────────────────────────────────────────────────────────

async function seed() {
  const col = db.collection('tickets');
  const batch = db.batch();

  for (const ticket of tickets) {
    batch.set(col.doc(ticket.id), ticket);
  }

  await batch.commit();
  console.log(`✓ Seeded ${tickets.length} tickets into Firestore (project: laporpak-fp)`);
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seeder failed:', err);
  process.exit(1);
});
