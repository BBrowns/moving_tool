// PostcodeAPI.nu integration
// Dutch address lookup by postal code + house number

import type { Address } from '../domain/project';

const POSTCODE_API_URL = 'https://api.postcodeapi.nu/v3';

interface PostcodeApiResponse {
    postcode: string;
    number: number;
    street: string;
    city: string;
    municipality: string;
    province: string;
}

/**
 * Look up address details from postal code and house number
 * Requires VITE_POSTCODE_API_KEY environment variable
 * 
 * Free tier: 1000 requests/month - sufficient for personal use
 * Get your key at: https://www.postcodeapi.nu/
 */
export async function lookupAddress(
    postcode: string,
    houseNumber: string
): Promise<Address | null> {
    const apiKey = import.meta.env.VITE_POSTCODE_API_KEY;

    // If no API key configured, return null (fallback to manual entry)
    if (!apiKey) {
        console.info('PostcodeAPI: No API key configured, using manual address entry');
        return null;
    }

    // Clean up postcode (remove spaces)
    const cleanPostcode = postcode.replace(/\s/g, '').toUpperCase();

    try {
        const response = await fetch(
            `${POSTCODE_API_URL}/lookup/${cleanPostcode}/${houseNumber}`,
            {
                headers: {
                    'X-Api-Key': apiKey,
                },
            }
        );

        if (!response.ok) {
            if (response.status === 404) {
                console.info('PostcodeAPI: Address not found');
                return null;
            }
            throw new Error(`PostcodeAPI error: ${response.status}`);
        }

        const data: PostcodeApiResponse = await response.json();

        return {
            street: data.street,
            houseNumber: houseNumber,
            postalCode: data.postcode,
            city: data.city,
        };
    } catch (error) {
        console.error('PostcodeAPI lookup failed:', error);
        return null;
    }
}

/**
 * Check if PostcodeAPI is configured
 */
export function isPostcodeApiConfigured(): boolean {
    return !!import.meta.env.VITE_POSTCODE_API_KEY;
}
