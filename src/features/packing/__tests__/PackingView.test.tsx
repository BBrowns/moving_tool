import { describe, it, expect, beforeEach, vi } from 'vitest';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { PackingView } from '../PackingView';
import { usePackingStore } from '../../../stores/packingStore';
import { useProjectStore } from '../../../stores/projectStore';
import { db } from '../../../db/database';

// Mock child components if complex, but here we want to test interaction?
// PackingModals is imported in PackingView. We want to see if it opens.
// We can test if "Naam kamer" appears or "Doos 1" appears.

describe('PackingView', () => {
    beforeEach(async () => {
        // Clear DB
        await db.rooms.clear();
        await db.boxes.clear();

        // Reset stores
        usePackingStore.setState({
            rooms: [],
            boxes: [],
            boxItems: [],
            isLoading: false
        });

        // Mock project store
        useProjectStore.setState({
            project: { id: 'p1', name: 'My Move', date: new Date(), createdAt: new Date() }
        });
    });

    it('should show empty state initially', () => {
        render(<PackingView />);
        expect(screen.getByText('Nog geen kamers')).toBeInTheDocument();
    });

    it('should open room modal when clicking add room', async () => {
        render(<PackingView />);
        fireEvent.click(screen.getByText('Kamer toevoegen'));
        expect(screen.getByText('Naam kamer')).toBeInTheDocument();
    });

    it('should add a room and then add a box which opens modal', async () => {
        // Pre-populate store with a room to skip room creation UI steps
        const { addRoom } = usePackingStore.getState();
        await addRoom('p1', 'Living Room');

        render(<PackingView />);

        // Verify room is there
        expect(screen.getByText('Living Room')).toBeInTheDocument();

        // Find "Add Box" button (+ Doos)
        const addBoxBtn = screen.getByText('+ Doos');
        fireEvent.click(addBoxBtn);

        // Wait for modal to appear
        // The modal title should be "Doos LI-1" (Living Room box 1)
        await waitFor(() => {
            // Check for modal specific content with regex to avoid whitespace issues
            expect(screen.getByText(/Label \(Optioneel\)/i)).toBeInTheDocument();
            // Check for "Inhoud" section
            expect(screen.getByText(/Inhoud/i)).toBeInTheDocument();
            // Check modal title - use more specific selector
            expect(screen.getByRole('heading', { name: /Doos LI-1/i })).toBeInTheDocument();
        }, { timeout: 3000 });
    });
});
