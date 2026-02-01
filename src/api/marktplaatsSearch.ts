// Marktplaats search integration
// Generate direct search URLs with filters

import type { ShoppingItem, ShoppingCategory } from '../domain/shopping';

/**
 * Marktplaats category mapping
 */
export const marktplaatsCategoryPaths: Record<ShoppingCategory, string> = {
    meubels: 'huis-en-inrichting/meubels',
    verlichting: 'huis-en-inrichting/lampen',
    keuken: 'huis-en-inrichting/keuken',
    decoratie: 'huis-en-inrichting/woonaccessoires',
    elektronica: 'computers-en-software',
    badkamer: 'huis-en-inrichting/badkamer',
    slaapkamer: 'huis-en-inrichting/slaapkamer',
    tuin: 'tuin-en-terras',
    overig: '',
};

interface SearchOptions {
    maxPrice?: number;        // in cents
    distanceKm?: number;      // search radius in km
    postcode?: string;        // for location-based search
    sortBy?: 'date' | 'price'; // sort results
}

/**
 * Generate Marktplaats search URL for a shopping item
 * Opens in new tab with search term and filters applied
 */
export function generateMarktplaatsSearchUrl(
    item: ShoppingItem,
    options?: SearchOptions
): string {
    const baseUrl = 'https://www.marktplaats.nl';

    // Get category path or use search
    const categoryPath = marktplaatsCategoryPaths[item.category];

    // Build search URL
    const searchTerm = encodeURIComponent(item.name);
    let url: string;

    if (categoryPath) {
        url = `${baseUrl}/l/${categoryPath}/#q:${searchTerm}`;
    } else {
        url = `${baseUrl}/q/${searchTerm}/`;
    }

    // Add query parameters
    const params = new URLSearchParams();

    if (options?.maxPrice) {
        // Convert cents to euros for Marktplaats
        const maxEuros = Math.floor(options.maxPrice / 100);
        params.set('priceFrom', '0');
        params.set('priceTo', String(maxEuros));
    }

    if (options?.distanceKm && options?.postcode) {
        params.set('distanceMeters', String(options.distanceKm * 1000));
        params.set('postcode', options.postcode.replace(/\s/g, ''));
    }

    if (options?.sortBy === 'price') {
        params.set('sortBy', 'PRICE');
    }

    const queryString = params.toString();
    if (queryString) {
        url += (url.includes('?') ? '&' : '?') + queryString;
    }

    return url;
}

/**
 * Open Marktplaats search in new tab
 */
export function openMarktplaatsSearch(
    item: ShoppingItem,
    options?: SearchOptions
): void {
    const url = generateMarktplaatsSearchUrl(item, options);
    window.open(url, '_blank', 'noopener,noreferrer');
}

/**
 * Check if a URL is a Marktplaats advertisement
 */
export function isMarktplaatsUrl(url: string): boolean {
    try {
        const parsed = new URL(url);
        return parsed.hostname.includes('marktplaats.nl');
    } catch {
        return false;
    }
}

/**
 * Extract basic info from Marktplaats URL
 * Note: This is basic - doesn't scrape the page
 */
export function parseMarktplaatsUrl(url: string): { isAd: boolean; adId?: string } {
    try {
        const parsed = new URL(url);
        // Marktplaats ads have format /v/category/m123456-title
        const match = parsed.pathname.match(/\/v\/[^/]+\/m(\d+)/);
        if (match) {
            return { isAd: true, adId: match[1] };
        }
        // Alternative format /a/category/advertentie/m123456
        const altMatch = parsed.pathname.match(/\/m(\d+)/);
        if (altMatch) {
            return { isAd: true, adId: altMatch[1] };
        }
        return { isAd: false };
    } catch {
        return { isAd: false };
    }
}
