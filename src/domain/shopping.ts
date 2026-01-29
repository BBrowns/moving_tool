// Domain models - Shopping
// Shopping list for items needed for new home

export type ShoppingStatus = 'needed' | 'found' | 'bought';

export type ShoppingCategory =
    | 'meubels'
    | 'verlichting'
    | 'keuken'
    | 'decoratie'
    | 'elektronica'
    | 'overig';

export interface SavedLink {
    url: string;
    title: string;
    price?: number;       // in cents
    addedAt: Date;
}

export interface ShoppingItem {
    id: string;
    projectId: string;
    name: string;
    category: ShoppingCategory;
    status: ShoppingStatus;
    maxPrice?: number;      // budget in cents
    actualPrice?: number;   // final price in cents
    notes?: string;
    savedLinks: SavedLink[]; // Marktplaats links, etc.
    createdAt: Date;
}

// Category labels for UI
export const SHOPPING_CATEGORY_LABELS: Record<ShoppingCategory, { label: string; emoji: string }> = {
    meubels: { label: 'Meubels', emoji: '🛋️' },
    verlichting: { label: 'Verlichting', emoji: '💡' },
    keuken: { label: 'Keuken', emoji: '🍳' },
    decoratie: { label: 'Decoratie', emoji: '🖼️' },
    elektronica: { label: 'Elektronica', emoji: '📱' },
    overig: { label: 'Overig', emoji: '📦' },
};

export const SHOPPING_STATUS_LABELS: Record<ShoppingStatus, { label: string; color: string }> = {
    needed: { label: 'Nodig', color: '#ef4444' },
    found: { label: 'Gevonden', color: '#f59e0b' },
    bought: { label: 'Gekocht', color: '#22c55e' },
};
