// Domain models - Project & User
// These are pure TypeScript types with no framework dependencies

export interface Address {
  street: string;
  houseNumber: string;
  postalCode: string;
  city: string;
}

export interface Project {
  id: string;
  name: string;
  movingDate: Date;
  newAddress: Address;
  currentAddress?: Address;
  createdAt: Date;
}

export interface User {
  id: string;
  projectId: string;
  name: string;
  color: string; // hex color for UI identification
}

// Helper to format address for display
export function formatAddress(address: Address): string {
  return `${address.street} ${address.houseNumber}, ${address.postalCode} ${address.city}`;
}
