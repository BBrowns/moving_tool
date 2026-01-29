// Shopping store - Zustand state management
// Manages shopping list items

import { create } from 'zustand';
import { nanoid } from 'nanoid';
import { db } from '../db/database';
import type { ShoppingItem, ShoppingStatus, ShoppingCategory, SavedLink } from '../domain/shopping';

interface ShoppingFilters {
    status?: ShoppingStatus;
    category?: ShoppingCategory;
}

interface ShoppingState {
    // State
    items: ShoppingItem[];
    filters: ShoppingFilters;
    isLoading: boolean;

    // Actions
    loadItems: (projectId: string) => Promise<void>;
    addItem: (item: Omit<ShoppingItem, 'id' | 'createdAt' | 'savedLinks'>) => Promise<ShoppingItem>;
    updateItem: (id: string, updates: Partial<ShoppingItem>) => Promise<void>;
    deleteItem: (id: string) => Promise<void>;

    // Status workflow
    setItemStatus: (id: string, status: ShoppingStatus) => Promise<void>;

    // Saved links (Marktplaats etc.)
    addSavedLink: (itemId: string, link: Omit<SavedLink, 'addedAt'>) => Promise<void>;
    removeSavedLink: (itemId: string, url: string) => Promise<void>;

    // Filters
    setFilters: (filters: ShoppingFilters) => void;
    clearFilters: () => void;
}

export const useShoppingStore = create<ShoppingState>((set, get) => ({
    items: [],
    filters: {},
    isLoading: true,

    loadItems: async (projectId) => {
        set({ isLoading: true });
        const items = await db.shoppingItems
            .where('projectId')
            .equals(projectId)
            .toArray();

        // Sort by status (needed first, then found, then bought)
        const statusOrder: Record<ShoppingStatus, number> = {
            needed: 0,
            found: 1,
            bought: 2,
        };
        items.sort((a, b) => statusOrder[a.status] - statusOrder[b.status]);

        set({ items, isLoading: false });
    },

    addItem: async (itemData) => {
        const item: ShoppingItem = {
            ...itemData,
            id: nanoid(),
            savedLinks: [],
            createdAt: new Date(),
        };

        await db.shoppingItems.add(item);
        set({ items: [...get().items, item] });
        return item;
    },

    updateItem: async (id, updates) => {
        const { items } = get();
        await db.shoppingItems.update(id, updates);
        set({
            items: items.map(i => i.id === id ? { ...i, ...updates } : i),
        });
    },

    deleteItem: async (id) => {
        const { items } = get();
        await db.shoppingItems.delete(id);
        set({ items: items.filter(i => i.id !== id) });
    },

    setItemStatus: async (id, status) => {
        const { updateItem } = get();
        await updateItem(id, { status });
    },

    addSavedLink: async (itemId, linkData) => {
        const { items } = get();
        const item = items.find(i => i.id === itemId);
        if (!item) return;

        const newLink: SavedLink = {
            ...linkData,
            addedAt: new Date(),
        };

        const updatedLinks = [...item.savedLinks, newLink];
        await db.shoppingItems.update(itemId, { savedLinks: updatedLinks });
        set({
            items: items.map(i =>
                i.id === itemId ? { ...i, savedLinks: updatedLinks } : i
            ),
        });
    },

    removeSavedLink: async (itemId, url) => {
        const { items } = get();
        const item = items.find(i => i.id === itemId);
        if (!item) return;

        const updatedLinks = item.savedLinks.filter(l => l.url !== url);
        await db.shoppingItems.update(itemId, { savedLinks: updatedLinks });
        set({
            items: items.map(i =>
                i.id === itemId ? { ...i, savedLinks: updatedLinks } : i
            ),
        });
    },

    setFilters: (filters) => {
        set({ filters: { ...get().filters, ...filters } });
    },

    clearFilters: () => {
        set({ filters: {} });
    },
}));

// Selector for filtered items
export function getFilteredItems(items: ShoppingItem[], filters: ShoppingFilters): ShoppingItem[] {
    return items.filter(item => {
        if (filters.status && item.status !== filters.status) return false;
        if (filters.category && item.category !== filters.category) return false;
        return true;
    });
}

// Get total budget vs spent
export function getShoppingStats(items: ShoppingItem[]): {
    totalBudget: number;
    totalSpent: number;
    needed: number;
    found: number;
    bought: number;
} {
    return items.reduce(
        (acc, item) => {
            if (item.maxPrice) acc.totalBudget += item.maxPrice;
            if (item.actualPrice && item.status === 'bought') {
                acc.totalSpent += item.actualPrice;
            }
            acc[item.status]++;
            return acc;
        },
        { totalBudget: 0, totalSpent: 0, needed: 0, found: 0, bought: 0 }
    );
}
