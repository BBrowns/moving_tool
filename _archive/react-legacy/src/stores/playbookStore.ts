// Playbook store - Zustand state management
// Manages journal entries, notes, and report generation

import { create } from 'zustand';
import { nanoid } from 'nanoid';
import { db } from '../db/database';
import type {
    JournalEntry,
    PlaybookNote,
    JournalEventType,
    JournalCategory,
} from '../domain/playbook';

// ============================================================================
// STORE INTERFACE
// ============================================================================

interface PlaybookState {
    // State
    journalEntries: JournalEntry[];
    notes: PlaybookNote[];
    isLoading: boolean;

    // Actions
    loadPlaybook: (projectId: string) => Promise<void>;

    // Journal entry actions
    addJournalEntry: (entry: Omit<JournalEntry, 'id'>) => Promise<JournalEntry>;
    updateJournalEntry: (id: string, updates: Partial<JournalEntry>) => Promise<void>;
    deleteJournalEntry: (id: string) => Promise<void>;
    toggleHighlight: (id: string) => Promise<void>;

    // Note actions
    addNote: (note: Omit<PlaybookNote, 'id' | 'createdAt' | 'updatedAt'>) => Promise<PlaybookNote>;
    updateNote: (id: string, updates: Partial<PlaybookNote>) => Promise<void>;
    deleteNote: (id: string) => Promise<void>;
    togglePinNote: (id: string) => Promise<void>;

    // Auto-logging helpers (called from other stores)
    logPurchase: (projectId: string, itemName: string, price: number, roomId?: string, itemId?: string) => Promise<void>;
    logTaskComplete: (projectId: string, taskName: string, taskId?: string) => Promise<void>;
    logExpense: (projectId: string, description: string, amount: number, roomId?: string, expenseId?: string) => Promise<void>;
    logPacking: (projectId: string, boxLabel: string, roomId?: string, boxId?: string) => Promise<void>;
    logMilestone: (projectId: string, title: string, description?: string) => Promise<void>;
}

// ============================================================================
// STORE IMPLEMENTATION
// ============================================================================

export const usePlaybookStore = create<PlaybookState>((set, get) => ({
    journalEntries: [],
    notes: [],
    isLoading: true,

    loadPlaybook: async (projectId) => {
        set({ isLoading: true });

        const journalEntries = await db.journalEntries
            .where('projectId')
            .equals(projectId)
            .reverse()
            .sortBy('timestamp');

        const notes = await db.playbookNotes
            .where('projectId')
            .equals(projectId)
            .toArray();

        // Sort notes: pinned first, then by date
        notes.sort((a, b) => {
            if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
            return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
        });

        set({ journalEntries, notes, isLoading: false });
    },

    // ========================================================================
    // JOURNAL ENTRY ACTIONS
    // ========================================================================

    addJournalEntry: async (entryData) => {
        const entry: JournalEntry = {
            ...entryData,
            id: nanoid(),
            timestamp: entryData.timestamp || new Date(),
        };

        await db.journalEntries.add(entry);
        const { journalEntries } = get();
        set({ journalEntries: [entry, ...journalEntries] });
        return entry;
    },

    updateJournalEntry: async (id, updates) => {
        const { journalEntries } = get();
        await db.journalEntries.update(id, updates);
        set({
            journalEntries: journalEntries.map(e =>
                e.id === id ? { ...e, ...updates } : e
            ),
        });
    },

    deleteJournalEntry: async (id) => {
        const { journalEntries } = get();
        await db.journalEntries.delete(id);
        set({ journalEntries: journalEntries.filter(e => e.id !== id) });
    },

    toggleHighlight: async (id) => {
        const { journalEntries } = get();
        const entry = journalEntries.find(e => e.id === id);
        if (entry) {
            const newValue = !entry.isHighlight;
            await db.journalEntries.update(id, { isHighlight: newValue });
            set({
                journalEntries: journalEntries.map(e =>
                    e.id === id ? { ...e, isHighlight: newValue } : e
                ),
            });
        }
    },

    // ========================================================================
    // NOTE ACTIONS
    // ========================================================================

    addNote: async (noteData) => {
        const now = new Date();
        const note: PlaybookNote = {
            ...noteData,
            id: nanoid(),
            createdAt: now,
            updatedAt: now,
        };

        await db.playbookNotes.add(note);
        const { notes } = get();

        // Insert in correct position (pinned first, then by date)
        const newNotes = note.isPinned
            ? [note, ...notes]
            : [...notes.filter(n => n.isPinned), note, ...notes.filter(n => !n.isPinned)];

        set({ notes: newNotes });
        return note;
    },

    updateNote: async (id, updates) => {
        const { notes } = get();
        const updatedData = { ...updates, updatedAt: new Date() };
        await db.playbookNotes.update(id, updatedData);
        set({
            notes: notes.map(n =>
                n.id === id ? { ...n, ...updatedData } : n
            ),
        });
    },

    deleteNote: async (id) => {
        const { notes } = get();
        await db.playbookNotes.delete(id);
        set({ notes: notes.filter(n => n.id !== id) });
    },

    togglePinNote: async (id) => {
        const { notes } = get();
        const note = notes.find(n => n.id === id);
        if (note) {
            const newValue = !note.isPinned;
            await db.playbookNotes.update(id, { isPinned: newValue, updatedAt: new Date() });

            // Re-sort notes
            const updatedNotes = notes.map(n =>
                n.id === id ? { ...n, isPinned: newValue } : n
            );
            updatedNotes.sort((a, b) => {
                if (a.isPinned !== b.isPinned) return a.isPinned ? -1 : 1;
                return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
            });

            set({ notes: updatedNotes });
        }
    },

    // ========================================================================
    // AUTO-LOGGING HELPERS
    // ========================================================================

    logPurchase: async (projectId, itemName, price, roomId, itemId) => {
        await get().addJournalEntry({
            projectId,
            timestamp: new Date(),
            eventType: 'purchase',
            eventCategory: 'acquisition',
            relatedEntityType: 'shopping_item',
            relatedEntityId: itemId,
            roomId,
            title: `🛒 ${itemName} gekocht`,
            monetaryValue: price,
            isAutoGenerated: true,
        });
    },

    logTaskComplete: async (projectId, taskName, taskId) => {
        await get().addJournalEntry({
            projectId,
            timestamp: new Date(),
            eventType: 'task_complete',
            eventCategory: 'admin',
            relatedEntityType: 'task',
            relatedEntityId: taskId,
            title: `✅ ${taskName}`,
            isAutoGenerated: true,
        });
    },

    logExpense: async (projectId, description, amount, roomId, expenseId) => {
        await get().addJournalEntry({
            projectId,
            timestamp: new Date(),
            eventType: 'expense',
            eventCategory: 'acquisition',
            relatedEntityType: 'expense',
            relatedEntityId: expenseId,
            roomId,
            title: `💰 ${description}`,
            monetaryValue: amount,
            isAutoGenerated: true,
        });
    },

    logPacking: async (projectId, boxLabel, roomId, boxId) => {
        await get().addJournalEntry({
            projectId,
            timestamp: new Date(),
            eventType: 'packing',
            eventCategory: 'packing',
            relatedEntityType: 'box',
            relatedEntityId: boxId,
            roomId,
            title: `📦 ${boxLabel} ingepakt`,
            isAutoGenerated: true,
        });
    },

    logMilestone: async (projectId, title, description) => {
        await get().addJournalEntry({
            projectId,
            timestamp: new Date(),
            eventType: 'milestone',
            eventCategory: 'custom',
            title: `🎯 ${title}`,
            description,
            isHighlight: true,
            isAutoGenerated: false,
        });
    },
}));

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get entries for a specific room
 */
export function getEntriesForRoom(entries: JournalEntry[], roomId: string): JournalEntry[] {
    return entries.filter(e => e.roomId === roomId);
}

/**
 * Get highlighted entries only
 */
export function getHighlightedEntries(entries: JournalEntry[]): JournalEntry[] {
    return entries.filter(e => e.isHighlight);
}

/**
 * Get entries by event type
 */
export function getEntriesByType(entries: JournalEntry[], eventType: JournalEventType): JournalEntry[] {
    return entries.filter(e => e.eventType === eventType);
}

/**
 * Get entries by category
 */
export function getEntriesByCategory(entries: JournalEntry[], category: JournalCategory): JournalEntry[] {
    return entries.filter(e => e.eventCategory === category);
}
