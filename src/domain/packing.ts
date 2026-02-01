// Domain models - Packing & Rooms
// Room, Box, and BoxItem management for packing/unpacking
// Extended with spatial planning, budgeting, and renovation tracking

// ============================================================================
// ROOM TYPES
// ============================================================================

export type RoomType =
    | 'woonkamer'
    | 'keuken'
    | 'slaapkamer'
    | 'badkamer'
    | 'toilet'
    | 'berging'
    | 'hal'
    | 'balkon'
    | 'tuin'
    | 'overig';

export const ROOM_TYPE_LABELS: Record<RoomType, { label: string; emoji: string }> = {
    woonkamer: { label: 'Woonkamer', emoji: '🛋️' },
    keuken: { label: 'Keuken', emoji: '🍳' },
    slaapkamer: { label: 'Slaapkamer', emoji: '🛏️' },
    badkamer: { label: 'Badkamer', emoji: '🚿' },
    toilet: { label: 'Toilet', emoji: '🚽' },
    berging: { label: 'Berging', emoji: '🗄️' },
    hal: { label: 'Hal/Entree', emoji: '🚪' },
    balkon: { label: 'Balkon', emoji: '🌤️' },
    tuin: { label: 'Tuin', emoji: '🌱' },
    overig: { label: 'Overig', emoji: '📦' },
};

// ============================================================================
// ROOM DIMENSIONS - For spatial calculations
// ============================================================================

export interface RoomDimensions {
    widthMm: number;             // Width in mm (from floor plan)
    lengthMm: number;            // Length in mm
    heightMm?: number;           // Ceiling height (default ~2500mm)
}

/**
 * Calculate room area in square meters from dimensions
 */
export function calculateRoomArea(dimensions: RoomDimensions): number {
    return (dimensions.widthMm * dimensions.lengthMm) / 1_000_000; // mm² to m²
}

/**
 * Calculate wall area for painting (excludes floor/ceiling)
 */
export function calculateWallArea(dimensions: RoomDimensions): number {
    const heightM = (dimensions.heightMm || 2500) / 1000;
    const perimeterM = 2 * ((dimensions.widthMm + dimensions.lengthMm) / 1000);
    return perimeterM * heightM;
}

// ============================================================================
// ROOM BUDGET - For financial planning per room
// ============================================================================

export interface RoomBudget {
    allocated: number;           // Total budget for this room (cents)
    // Note: 'spent' is calculated dynamically from linked expenses
}

// ============================================================================
// ROOM RENOVATION - For tracking renovation work
// ============================================================================

export interface RoomRenovation {
    wallColor?: string;          // Paint color name
    wallColorHex?: string;       // Hex color for visual preview
    wallColorCode?: string;      // RAL/NCS code
    floorType?: string;          // e.g., "Laminaat", "Tegels", "Parket"
    ceilingColor?: string;
    renovationNotes?: string;
    isCompleted: boolean;
}

// ============================================================================
// ROOM - Main entity with all extensions
// ============================================================================

export interface Room {
    id: string;
    projectId: string;
    name: string;
    roomType: RoomType;
    color: string;               // hex color for visual grouping
    order: number;               // for sorting

    // Spatial data (from floor plan)
    dimensions?: RoomDimensions;

    // Budgeting
    budget?: RoomBudget;

    // Renovation tracking
    renovation?: RoomRenovation;

    // Floor plan positioning (for future canvas feature)
    floorPlanPosition?: {
        x: number;               // X position on canvas
        y: number;               // Y position on canvas
        width: number;           // Display width
        height: number;          // Display height
    };

    // Metadata
    createdAt?: Date;
    updatedAt?: Date;
}

// ============================================================================
// BOX - Packing container
// ============================================================================

export type BoxPriority = 'low' | 'medium' | 'high';
export type BoxStatus = 'empty' | 'packing' | 'packed' | 'moved' | 'unpacked';

export interface Box {
    id: string;
    roomId: string;
    number: number;              // Sequential per room (e.g., WK-1, WK-2)
    label?: string;              // Optional custom label (e.g., "Boeken")
    isFragile: boolean;
    priority: BoxPriority;
    status: BoxStatus;           // NEW: Track packing progress

    // Location tracking
    destinationRoomId?: string;  // Which room in new home
    currentLocation?: string;    // "Woonkamer", "Verhuiswagen", etc.

    createdAt: Date;
}

// Priority labels for UI
export const BOX_PRIORITY_LABELS: Record<BoxPriority, { label: string; emoji: string }> = {
    low: { label: 'Laag', emoji: '🔵' },
    medium: { label: 'Medium', emoji: '🟡' },
    high: { label: 'Hoog', emoji: '🔴' },
};

export const BOX_STATUS_LABELS: Record<BoxStatus, { label: string; color: string }> = {
    empty: { label: 'Leeg', color: '#6b7280' },
    packing: { label: 'Bezig', color: '#f59e0b' },
    packed: { label: 'Ingepakt', color: '#3b82f6' },
    moved: { label: 'Verhuisd', color: '#8b5cf6' },
    unpacked: { label: 'Uitgepakt', color: '#22c55e' },
};

// ============================================================================
// BOX ITEM - Contents of a box
// ============================================================================

export interface BoxItem {
    id: string;
    boxId: string;
    description: string;
    order: number;               // for sorting within box
    isFragile?: boolean;         // Individual item fragility
    quantity?: number;           // How many of this item
    photoUrl?: string;           // Optional photo for inventory
}

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

/**
 * Generate box code like "WK-1" from room name and number
 */
export function getBoxCode(roomName: string, boxNumber: number): string {
    // Take first 2 letters of room, uppercase
    const prefix = roomName.substring(0, 2).toUpperCase();
    return `${prefix}-${boxNumber}`;
}

/**
 * Get room display name with type emoji
 */
export function getRoomDisplayName(room: Room): string {
    const typeInfo = ROOM_TYPE_LABELS[room.roomType];
    return `${typeInfo?.emoji || '📦'} ${room.name}`;
}

/**
 * Calculate room area from dimensions (returns m²)
 */
export function getRoomAreaSqM(room: Room): number | undefined {
    if (!room.dimensions) return undefined;
    return calculateRoomArea(room.dimensions);
}

/**
 * Get budget remaining for a room
 */
export function getRoomBudgetRemaining(room: Room, spentAmount: number): number {
    const allocated = room.budget?.allocated || 0;
    return allocated - spentAmount;
}
