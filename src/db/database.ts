// Dexie database setup
// IndexedDB wrapper for offline-first persistence

import Dexie, { type Table } from 'dexie';
import type { Project, User } from '../domain/project';
import type { Task } from '../domain/task';
import type { Room, Box, BoxItem } from '../domain/packing';
import type { ShoppingItem } from '../domain/shopping';
import type { Expense } from '../domain/cost';
import type { JournalEntry, PlaybookNote } from '../domain/playbook';

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
    journalEntries!: Table<JournalEntry>;
    playbookNotes!: Table<PlaybookNote>;

    constructor() {
        super('MovingToolDB');

        // ================================================================
        // VERSION 1 - Original schema
        // ================================================================
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

        // ================================================================
        // VERSION 2 - Extended schema with acquisition types and linking
        // ================================================================
        this.version(2).stores({
            projects: 'id, createdAt',
            users: 'id, projectId',
            tasks: 'id, projectId, assigneeId, status, category, deadline',
            rooms: 'id, projectId, order, roomType',
            boxes: 'id, roomId, number, status',
            boxItems: 'id, boxId, order',
            shoppingItems: 'id, projectId, status, category, acquisitionType, roomId',
            expenses: 'id, projectId, paidById, date, roomId, shoppingItemId',
        }).upgrade(tx => {
            return tx.table('shoppingItems').toCollection().modify(item => {
                if (!item.acquisitionType) {
                    item.acquisitionType = 'retail';
                }
                if (!item.status) {
                    item.status = 'needed';
                }
            });
        });

        // ================================================================
        // VERSION 3 - Room type defaults
        // ================================================================
        this.version(3).stores({
            projects: 'id, createdAt',
            users: 'id, projectId',
            tasks: 'id, projectId, assigneeId, status, category, deadline',
            rooms: 'id, projectId, order, roomType',
            boxes: 'id, roomId, number, status',
            boxItems: 'id, boxId, order',
            shoppingItems: 'id, projectId, status, category, acquisitionType, roomId',
            expenses: 'id, projectId, paidById, date, roomId, shoppingItemId',
        }).upgrade(tx => {
            return tx.table('rooms').toCollection().modify(room => {
                if (!room.roomType) {
                    room.roomType = 'overig';
                }
            });
        });

        // ================================================================
        // VERSION 4 - Box status default
        // ================================================================
        this.version(4).stores({
            projects: 'id, createdAt',
            users: 'id, projectId',
            tasks: 'id, projectId, assigneeId, status, category, deadline',
            rooms: 'id, projectId, order, roomType',
            boxes: 'id, roomId, number, status',
            boxItems: 'id, boxId, order',
            shoppingItems: 'id, projectId, status, category, acquisitionType, roomId',
            expenses: 'id, projectId, paidById, date, roomId, shoppingItemId',
        }).upgrade(tx => {
            return tx.table('boxes').toCollection().modify(box => {
                if (!box.status) {
                    box.status = 'empty';
                }
            });
        });

        // ================================================================
        // VERSION 5 - Playbook: Journal entries and notes
        // ================================================================
        this.version(5).stores({
            projects: 'id, createdAt',
            users: 'id, projectId',
            tasks: 'id, projectId, assigneeId, status, category, deadline',
            rooms: 'id, projectId, order, roomType',
            boxes: 'id, roomId, number, status',
            boxItems: 'id, boxId, order',
            shoppingItems: 'id, projectId, status, category, acquisitionType, roomId',
            expenses: 'id, projectId, paidById, date, roomId, shoppingItemId',
            // NEW: Journal entries for event log
            journalEntries: 'id, projectId, timestamp, eventType, eventCategory, roomId, relatedEntityId',
            // NEW: Playbook notes for manual entries
            playbookNotes: 'id, projectId, createdAt, roomId, isPinned',
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
    await db.journalEntries.clear();
    await db.playbookNotes.clear();
}
