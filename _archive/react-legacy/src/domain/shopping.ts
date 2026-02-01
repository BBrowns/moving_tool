// Domain models - Shopping / Acquisition
// Manages all types of acquisitions: marketplace purchases, retail shopping, services, renovation supplies

// ============================================================================
// ACQUISITION TYPE - Discriminated union for different procurement workflows
// ============================================================================

export type AcquisitionType =
    | 'marketplace'    // Marktplaats, Facebook Marketplace - negotiation flow
    | 'retail'         // IKEA, Action, Gamma - simple shopping list
    | 'service'        // Energy supplier, Internet - contract workflow
    | 'renovation';    // Paint, supplies - area/volume calculation context

export const ACQUISITION_TYPE_LABELS: Record<AcquisitionType, { label: string; emoji: string; description: string }> = {
    marketplace: { label: 'Tweedehands', emoji: '🛒', description: 'Marktplaats, Facebook Marketplace' },
    retail: { label: 'Winkel', emoji: '🏪', description: 'IKEA, Action, Gamma' },
    service: { label: 'Dienst', emoji: '📋', description: 'Energie, Internet, Verzekering' },
    renovation: { label: 'Verbouwing', emoji: '🔧', description: 'Verf, materialen' },
};

// ============================================================================
// STATUS TYPES
// ============================================================================

// Generic status for retail items
export type ShoppingStatus = 'needed' | 'found' | 'bought';

// Marketplace-specific negotiation status
export type NegotiationStatus =
    | 'watching'       // Saved listing, not yet contacted
    | 'contacted'      // First message sent
    | 'negotiating'    // Back-and-forth with seller
    | 'agreed'         // Price agreed, pickup pending
    | 'won'            // Pickup complete, item acquired
    | 'lost';          // Sold to someone else / fell through

// Service contract status
export type ServiceStatus =
    | 'researching'    // Comparing options
    | 'applied'        // Application submitted
    | 'pending'        // Waiting for activation
    | 'active'         // Service is live
    | 'cancelled';     // Service cancelled

export const SHOPPING_STATUS_LABELS: Record<ShoppingStatus, { label: string; color: string }> = {
    needed: { label: 'Nodig', color: '#ef4444' },
    found: { label: 'Gevonden', color: '#f59e0b' },
    bought: { label: 'Gekocht', color: '#22c55e' },
};

export const NEGOTIATION_STATUS_LABELS: Record<NegotiationStatus, { label: string; color: string; emoji: string }> = {
    watching: { label: 'In de gaten', color: '#6b7280', emoji: '👀' },
    contacted: { label: 'Benaderd', color: '#3b82f6', emoji: '💬' },
    negotiating: { label: 'Onderhandelen', color: '#f59e0b', emoji: '🤝' },
    agreed: { label: 'Afgesproken', color: '#8b5cf6', emoji: '✅' },
    won: { label: 'Gekocht', color: '#22c55e', emoji: '🎉' },
    lost: { label: 'Gemist', color: '#ef4444', emoji: '❌' },
};

export const SERVICE_STATUS_LABELS: Record<ServiceStatus, { label: string; color: string }> = {
    researching: { label: 'Onderzoeken', color: '#6b7280' },
    applied: { label: 'Aangevraagd', color: '#3b82f6' },
    pending: { label: 'In afwachting', color: '#f59e0b' },
    active: { label: 'Actief', color: '#22c55e' },
    cancelled: { label: 'Geannuleerd', color: '#ef4444' },
};

// ============================================================================
// CATEGORIES
// ============================================================================

export type ShoppingCategory =
    | 'meubels'
    | 'verlichting'
    | 'keuken'
    | 'decoratie'
    | 'elektronica'
    | 'badkamer'
    | 'slaapkamer'
    | 'tuin'
    | 'overig';

export type ServiceCategory =
    | 'energie'
    | 'internet'
    | 'verzekering'
    | 'water'
    | 'gemeente'
    | 'overig';

export type RenovationCategory =
    | 'verf'
    | 'vloer'
    | 'behang'
    | 'gereedschap'
    | 'bevestiging'
    | 'overig';

export const SHOPPING_CATEGORY_LABELS: Record<ShoppingCategory, { label: string; emoji: string }> = {
    meubels: { label: 'Meubels', emoji: '🛋️' },
    verlichting: { label: 'Verlichting', emoji: '💡' },
    keuken: { label: 'Keuken', emoji: '🍳' },
    decoratie: { label: 'Decoratie', emoji: '🖼️' },
    elektronica: { label: 'Elektronica', emoji: '📱' },
    badkamer: { label: 'Badkamer', emoji: '🚿' },
    slaapkamer: { label: 'Slaapkamer', emoji: '🛏️' },
    tuin: { label: 'Tuin/Balkon', emoji: '🌱' },
    overig: { label: 'Overig', emoji: '📦' },
};

export const SERVICE_CATEGORY_LABELS: Record<ServiceCategory, { label: string; emoji: string }> = {
    energie: { label: 'Energie', emoji: '⚡' },
    internet: { label: 'Internet', emoji: '📶' },
    verzekering: { label: 'Verzekering', emoji: '🛡️' },
    water: { label: 'Water', emoji: '💧' },
    gemeente: { label: 'Gemeente', emoji: '🏛️' },
    overig: { label: 'Overig', emoji: '📋' },
};

export const RENOVATION_CATEGORY_LABELS: Record<RenovationCategory, { label: string; emoji: string }> = {
    verf: { label: 'Verf', emoji: '🎨' },
    vloer: { label: 'Vloer', emoji: '🪵' },
    behang: { label: 'Behang', emoji: '🧱' },
    gereedschap: { label: 'Gereedschap', emoji: '🔨' },
    bevestiging: { label: 'Bevestiging', emoji: '🔩' },
    overig: { label: 'Overig', emoji: '🔧' },
};

// ============================================================================
// MARKETPLACE DATA - For secondhand purchases with negotiation
// ============================================================================

export type MarketplacePlatform = 'marktplaats' | 'facebook' | 'vinted' | 'other';

export type PaymentMethod = 'cash' | 'tikkie' | 'bank' | 'paypal';

export interface MarketplaceData {
    platform: MarketplacePlatform;
    listingUrl?: string;
    sellerName?: string;
    sellerLocation?: string;     // For calculating travel distance
    sellerPhone?: string;
    negotiationStatus: NegotiationStatus;
    askingPrice?: number;        // Original listing price (cents)
    offerPrice?: number;         // Your bid (cents)
    agreedPrice?: number;        // Final negotiated price (cents)
    pickupDate?: Date;           // Scheduled pickup
    pickupCompleted: boolean;
    paymentMethod?: PaymentMethod;
    conversationNotes?: string;  // Track negotiation history
}

// ============================================================================
// RENOVATION DATA - For paint, supplies with area/volume calculations
// ============================================================================

export interface RenovationData {
    renovationCategory: RenovationCategory;
    areaSqM?: number;            // m² needed (walls, floor)
    volumeL?: number;            // liters needed
    coveragePerUnit?: number;    // m² per liter/unit
    coats?: number;              // number of coats (for paint)
    calculatedQuantity?: number; // auto-calculated amount to buy
    colorCode?: string;          // RAL/NCS color code
    colorName?: string;          // Human readable color name
}

// ============================================================================
// SERVICE DATA - For utility/contract tracking
// ============================================================================

export interface ServiceData {
    serviceCategory: ServiceCategory;
    providerName?: string;
    contractNumber?: string;
    monthlyRate?: number;        // Monthly cost (cents)
    startDate?: Date;
    contractEndDate?: Date;
    status: ServiceStatus;
    activationNotes?: string;
    loginUrl?: string;           // Portal URL
    customerServicePhone?: string;
}

// ============================================================================
// SAVED LINKS - External links to listings/products
// ============================================================================

export interface SavedLink {
    url: string;
    title: string;
    price?: number;              // in cents
    addedAt: Date;
    platform?: MarketplacePlatform;
    thumbnail?: string;          // Image URL if available
}

// ============================================================================
// MAIN SHOPPING ITEM - Unified item with type-specific data
// ============================================================================

export interface ShoppingItem {
    id: string;
    projectId: string;
    name: string;

    // Type discrimination
    acquisitionType: AcquisitionType;

    // Category (type depends on acquisitionType)
    category: ShoppingCategory;  // For marketplace/retail

    // Generic status (for retail)
    status: ShoppingStatus;

    // Pricing
    maxPrice?: number;           // budget in cents
    actualPrice?: number;        // final price in cents

    // Room linking for spatial planning
    roomId?: string;             // Links to Room for budget tracking

    // Notes and links
    notes?: string;
    savedLinks: SavedLink[];

    // Type-specific data (only one will be populated based on acquisitionType)
    marketplace?: MarketplaceData;
    renovation?: RenovationData;
    service?: ServiceData;

    // Metadata
    createdAt: Date;
    updatedAt?: Date;
    completedAt?: Date;          // When item was bought/service activated
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Get the effective status of an item based on its acquisition type
 */
export function getEffectiveStatus(item: ShoppingItem): string {
    switch (item.acquisitionType) {
        case 'marketplace':
            return item.marketplace?.negotiationStatus || 'watching';
        case 'service':
            return item.service?.status || 'researching';
        default:
            return item.status;
    }
}

/**
 * Check if an item is completed (bought, won, or service active)
 */
export function isItemCompleted(item: ShoppingItem): boolean {
    switch (item.acquisitionType) {
        case 'marketplace':
            return item.marketplace?.negotiationStatus === 'won';
        case 'service':
            return item.service?.status === 'active';
        default:
            return item.status === 'bought';
    }
}

/**
 * Get the final price of an item
 */
export function getFinalPrice(item: ShoppingItem): number | undefined {
    if (item.acquisitionType === 'marketplace' && item.marketplace?.agreedPrice) {
        return item.marketplace.agreedPrice;
    }
    return item.actualPrice;
}

/**
 * Calculate renovation quantity based on area and coverage
 */
export function calculateRenovationQuantity(data: RenovationData): number | undefined {
    if (!data.areaSqM || !data.coveragePerUnit) return undefined;
    const baseQuantity = data.areaSqM / data.coveragePerUnit;
    const withCoats = data.coats ? baseQuantity * data.coats : baseQuantity;
    return Math.ceil(withCoats * 1.1); // Add 10% buffer
}
