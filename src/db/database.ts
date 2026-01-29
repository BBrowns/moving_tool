// Dexie database setup
// IndexedDB wrapper for offline-first persistence

import Dexie, { type Table } from 'dexie';
import type { Project, User } from '../domain/project';
import type { Task } from '../domain/task';
import type { Room, Box, BoxItem } from '../domain/packing';
import type { ShoppingItem } from '../domain/shopping';
import type { Expense } from '../domain/cost';

export class MovingToolDB extends Dexie {
    // Declare tables with their types
    projects!: Table<Project>;
    users!: Table<User>;
    tasks!: Table<Task>;
    rooms!: Table<Room>;
    boxes!: Table<Box>;
    boxItems!: Table<BoxItem>;
    shoppingItems!: Table<ShoppingItem>;
    expenses!: Table<Expense>;

    constructor() {
        super('MovingToolDB');

        // Schema definition
        // Indexed fields are listed after the primary key (id)
        this.version(1).stores({
            projects: 'id, createdAt',
            users: 'id, projectId',
            tasks: 'id, projectId, assigneeId, status, category, deadline',
            rooms: 'id, projectId, order',
            boxes: 'id, roomId, number',
            boxItems: 'id, boxId, order',
            shoppingItems: 'id, projectId, status, category',
            expenses: 'id, projectId, paidById, date',
        });
    }
}

// Single database instance
export const db = new MovingToolDB();

// Helper to clear all data (useful for testing/reset)
export async function clearDatabase(): Promise<void> {
    await db.projects.clear();
    await db.users.clear();
    await db.tasks.clear();
    await db.rooms.clear();
    await db.boxes.clear();
    await db.boxItems.clear();
    await db.shoppingItems.clear();
    await db.expenses.clear();
}
