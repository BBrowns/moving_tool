// PlaybookView - Journal timeline and notes
// The "crown jewel" feature for documenting the relocation journey

import { useState, useEffect, useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useProjectStore, usePlaybookStore, usePackingStore } from '../../stores';
import type { JournalEntry, PlaybookNote, JournalEventType, JournalCategory } from '../../domain/playbook';
import {
    JOURNAL_EVENT_LABELS,
    JOURNAL_CATEGORY_LABELS,
    groupEntriesByDate,
    formatJournalDate,
    getRelativeTime,
    calculateJournalStats,
} from '../../domain/playbook';
import { formatCurrency } from '../../domain/cost';
import { ROOM_TYPE_LABELS } from '../../domain/packing';
import { Modal } from '../../components/common/Modal';
import './playbook.css';

type ViewMode = 'timeline' | 'notes';
type FilterType = 'all' | JournalEventType | JournalCategory;

export function PlaybookView() {
    const { project } = useProjectStore();
    const {
        journalEntries,
        notes,
        isLoading,
        loadPlaybook,
        addNote,
        updateNote,
        deleteNote,
        toggleHighlight,
        togglePinNote,
        logMilestone,
    } = usePlaybookStore();
    const { rooms } = usePackingStore();

    // State
    const [viewMode, setViewMode] = useState<ViewMode>('timeline');
    const [filter, setFilter] = useState<FilterType>('all');
    const [showAddModal, setShowAddModal] = useState(false);
    const [editingNote, setEditingNote] = useState<PlaybookNote | null>(null);

    // Form state
    const [noteTitle, setNoteTitle] = useState('');
    const [noteContent, setNoteContent] = useState('');
    const [noteRoomId, setNoteRoomId] = useState('');
    const [noteTags, setNoteTags] = useState('');

    // Load data
    useEffect(() => {
        if (project?.id) {
            loadPlaybook(project.id);
        }
    }, [project?.id, loadPlaybook]);

    // Filter entries
    const filteredEntries = useMemo(() => {
        if (filter === 'all') return journalEntries;
        // Check if filter is an event type or category
        if (['purchase', 'task_complete', 'expense', 'packing', 'milestone', 'note'].includes(filter)) {
            return journalEntries.filter(e => e.eventType === filter);
        }
        return journalEntries.filter(e => e.eventCategory === filter);
    }, [journalEntries, filter]);

    // Group by date for timeline
    const groupedEntries = useMemo(() => groupEntriesByDate(filteredEntries), [filteredEntries]);

    // Stats
    const stats = useMemo(() => calculateJournalStats(journalEntries), [journalEntries]);

    // Handlers
    const handleAddNote = async () => {
        if (!project || !noteTitle.trim()) return;

        await addNote({
            projectId: project.id,
            title: noteTitle,
            content: noteContent,
            tags: noteTags.split(',').map(t => t.trim()).filter(Boolean),
            roomId: noteRoomId || undefined,
            isPinned: false,
        });

        resetForm();
        setShowAddModal(false);
    };

    const handleUpdateNote = async () => {
        if (!editingNote || !noteTitle.trim()) return;

        await updateNote(editingNote.id, {
            title: noteTitle,
            content: noteContent,
            tags: noteTags.split(',').map(t => t.trim()).filter(Boolean),
            roomId: noteRoomId || undefined,
        });

        resetForm();
        setEditingNote(null);
    };

    const handleAddMilestone = async () => {
        if (!project || !noteTitle.trim()) return;

        await logMilestone(project.id, noteTitle, noteContent);

        resetForm();
        setShowAddModal(false);
    };

    const resetForm = () => {
        setNoteTitle('');
        setNoteContent('');
        setNoteRoomId('');
        setNoteTags('');
    };

    const openEditNote = (note: PlaybookNote) => {
        setNoteTitle(note.title);
        setNoteContent(note.content);
        setNoteRoomId(note.roomId || '');
        setNoteTags(note.tags.join(', '));
        setEditingNote(note);
    };

    const getRoomName = (roomId: string | undefined) => {
        if (!roomId) return null;
        const room = rooms.find(r => r.id === roomId);
        if (!room) return null;
        const typeInfo = ROOM_TYPE_LABELS[room.roomType];
        return `${typeInfo?.emoji || '📦'} ${room.name}`;
    };

    if (isLoading) {
        return (
            <div className="playbook-view">
                <div className="loading-state">
                    <div className="loading-spinner" />
                    <p>Playbook laden...</p>
                </div>
            </div>
        );
    }

    return (
        <div className="playbook-view">
            {/* Header */}
            <header className="page-header">
                <div>
                    <h1 className="page-title">📓 Playbook</h1>
                    <p className="page-subtitle">
                        Jouw verhuisverhaal - alle mijlpalen en notities
                    </p>
                </div>
                <div className="header-actions">
                    <button
                        className="btn btn-secondary"
                        onClick={() => setShowAddModal(true)}
                    >
                        + Toevoegen
                    </button>
                </div>
            </header>

            {/* Stats Bar */}
            <div className="playbook-stats">
                <div className="stat-card">
                    <span className="stat-emoji">🛒</span>
                    <div className="stat-info">
                        <span className="stat-value">{stats.purchases}</span>
                        <span className="stat-label">Aankopen</span>
                    </div>
                </div>
                <div className="stat-card">
                    <span className="stat-emoji">✅</span>
                    <div className="stat-info">
                        <span className="stat-value">{stats.tasksCompleted}</span>
                        <span className="stat-label">Taken</span>
                    </div>
                </div>
                <div className="stat-card">
                    <span className="stat-emoji">💰</span>
                    <div className="stat-info">
                        <span className="stat-value">{formatCurrency(stats.totalSpent)}</span>
                        <span className="stat-label">Uitgegeven</span>
                    </div>
                </div>
                <div className="stat-card">
                    <span className="stat-emoji">⭐</span>
                    <div className="stat-info">
                        <span className="stat-value">{stats.highlights}</span>
                        <span className="stat-label">Highlights</span>
                    </div>
                </div>
            </div>

            {/* View Toggle */}
            <div className="view-toggle-bar">
                <div className="view-tabs">
                    <button
                        className={`view-tab ${viewMode === 'timeline' ? 'active' : ''}`}
                        onClick={() => setViewMode('timeline')}
                    >
                        📅 Tijdlijn
                    </button>
                    <button
                        className={`view-tab ${viewMode === 'notes' ? 'active' : ''}`}
                        onClick={() => setViewMode('notes')}
                    >
                        📝 Notities ({notes.length})
                    </button>
                </div>

                {viewMode === 'timeline' && (
                    <select
                        className="filter-select"
                        value={filter}
                        onChange={e => setFilter(e.target.value as FilterType)}
                    >
                        <option value="all">Alle gebeurtenissen</option>
                        <optgroup label="Type">
                            {Object.entries(JOURNAL_EVENT_LABELS).map(([key, { label, emoji }]) => (
                                <option key={key} value={key}>{emoji} {label}</option>
                            ))}
                        </optgroup>
                        <optgroup label="Categorie">
                            {Object.entries(JOURNAL_CATEGORY_LABELS).map(([key, { label }]) => (
                                <option key={key} value={key}>{label}</option>
                            ))}
                        </optgroup>
                    </select>
                )}
            </div>

            {/* Content */}
            <div className="playbook-content">
                {viewMode === 'timeline' ? (
                    <TimelineView
                        groupedEntries={groupedEntries}
                        onToggleHighlight={toggleHighlight}
                        getRoomName={getRoomName}
                    />
                ) : (
                    <NotesView
                        notes={notes}
                        onEdit={openEditNote}
                        onDelete={deleteNote}
                        onTogglePin={togglePinNote}
                        getRoomName={getRoomName}
                    />
                )}
            </div>

            {/* Add Modal */}
            <Modal
                isOpen={showAddModal}
                onClose={() => { setShowAddModal(false); resetForm(); }}
                title="Toevoegen aan Playbook"
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={() => { setShowAddModal(false); resetForm(); }}>
                            Annuleren
                        </button>
                        <button className="btn btn-primary" onClick={handleAddNote}>
                            📝 Notitie opslaan
                        </button>
                        <button className="btn btn-accent" onClick={handleAddMilestone}>
                            🎯 Als mijlpaal
                        </button>
                    </>
                }
            >
                <div className="note-form">
                    <div className="form-group">
                        <label className="form-label">Titel *</label>
                        <input
                            type="text"
                            className="form-input"
                            value={noteTitle}
                            onChange={e => setNoteTitle(e.target.value)}
                            placeholder="bijv. Sleuteloverdracht, Eerste nacht in nieuwe huis"
                        />
                    </div>
                    <div className="form-group">
                        <label className="form-label">Beschrijving</label>
                        <textarea
                            className="form-input form-textarea"
                            value={noteContent}
                            onChange={e => setNoteContent(e.target.value)}
                            rows={4}
                            placeholder="Beschrijf dit moment of deze notitie..."
                        />
                    </div>
                    <div className="form-row">
                        <div className="form-group">
                            <label className="form-label">Kamer (optioneel)</label>
                            <select
                                className="form-input form-select"
                                value={noteRoomId}
                                onChange={e => setNoteRoomId(e.target.value)}
                            >
                                <option value="">Geen kamer</option>
                                {rooms.map(room => {
                                    const typeInfo = ROOM_TYPE_LABELS[room.roomType];
                                    return (
                                        <option key={room.id} value={room.id}>
                                            {typeInfo?.emoji} {room.name}
                                        </option>
                                    );
                                })}
                            </select>
                        </div>
                        <div className="form-group">
                            <label className="form-label">Tags (komma gescheiden)</label>
                            <input
                                type="text"
                                className="form-input"
                                value={noteTags}
                                onChange={e => setNoteTags(e.target.value)}
                                placeholder="bijv. renovatie, woonkamer, tip"
                            />
                        </div>
                    </div>
                </div>
            </Modal>

            {/* Edit Note Modal */}
            <Modal
                isOpen={!!editingNote}
                onClose={() => { setEditingNote(null); resetForm(); }}
                title="Notitie bewerken"
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={() => { setEditingNote(null); resetForm(); }}>
                            Annuleren
                        </button>
                        <button className="btn btn-primary" onClick={handleUpdateNote}>
                            Opslaan
                        </button>
                    </>
                }
            >
                <div className="note-form">
                    <div className="form-group">
                        <label className="form-label">Titel *</label>
                        <input
                            type="text"
                            className="form-input"
                            value={noteTitle}
                            onChange={e => setNoteTitle(e.target.value)}
                        />
                    </div>
                    <div className="form-group">
                        <label className="form-label">Beschrijving</label>
                        <textarea
                            className="form-input form-textarea"
                            value={noteContent}
                            onChange={e => setNoteContent(e.target.value)}
                            rows={4}
                        />
                    </div>
                    <div className="form-row">
                        <div className="form-group">
                            <label className="form-label">Kamer (optioneel)</label>
                            <select
                                className="form-input form-select"
                                value={noteRoomId}
                                onChange={e => setNoteRoomId(e.target.value)}
                            >
                                <option value="">Geen kamer</option>
                                {rooms.map(room => {
                                    const typeInfo = ROOM_TYPE_LABELS[room.roomType];
                                    return (
                                        <option key={room.id} value={room.id}>
                                            {typeInfo?.emoji} {room.name}
                                        </option>
                                    );
                                })}
                            </select>
                        </div>
                        <div className="form-group">
                            <label className="form-label">Tags</label>
                            <input
                                type="text"
                                className="form-input"
                                value={noteTags}
                                onChange={e => setNoteTags(e.target.value)}
                            />
                        </div>
                    </div>
                </div>
            </Modal>
        </div>
    );
}

// ============================================================================
// TIMELINE VIEW COMPONENT
// ============================================================================

interface TimelineViewProps {
    groupedEntries: Map<string, JournalEntry[]>;
    onToggleHighlight: (id: string) => Promise<void>;
    getRoomName: (roomId: string | undefined) => string | null;
}

function TimelineView({ groupedEntries, onToggleHighlight, getRoomName }: TimelineViewProps) {
    if (groupedEntries.size === 0) {
        return (
            <div className="empty-state">
                <div className="empty-state-icon">📅</div>
                <h2>Nog geen gebeurtenissen</h2>
                <p>
                    Gebeurtenissen verschijnen automatisch wanneer je aankopen doet,
                    taken afrondt, of dozen inpakt. Je kunt ook handmatig mijlpalen toevoegen.
                </p>
            </div>
        );
    }

    return (
        <div className="timeline">
            {Array.from(groupedEntries.entries()).map(([dateKey, entries]) => (
                <div key={dateKey} className="timeline-day">
                    <div className="timeline-date">
                        {formatJournalDate(new Date(dateKey))}
                    </div>
                    <div className="timeline-entries">
                        <AnimatePresence>
                            {entries.map(entry => (
                                <TimelineEntry
                                    key={entry.id}
                                    entry={entry}
                                    onToggleHighlight={onToggleHighlight}
                                    roomName={getRoomName(entry.roomId)}
                                />
                            ))}
                        </AnimatePresence>
                    </div>
                </div>
            ))}
        </div>
    );
}

// ============================================================================
// TIMELINE ENTRY COMPONENT
// ============================================================================

interface TimelineEntryProps {
    entry: JournalEntry;
    onToggleHighlight: (id: string) => Promise<void>;
    roomName: string | null;
}

function TimelineEntry({ entry, onToggleHighlight, roomName }: TimelineEntryProps) {
    const eventInfo = JOURNAL_EVENT_LABELS[entry.eventType];
    const categoryInfo = JOURNAL_CATEGORY_LABELS[entry.eventCategory];

    return (
        <motion.div
            layout
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: 20 }}
            className={`timeline-entry ${entry.isHighlight ? 'highlight' : ''}`}
        >
            <div className="entry-icon" style={{ backgroundColor: categoryInfo.color }}>
                {eventInfo.emoji}
            </div>
            <div className="entry-content">
                <div className="entry-header">
                    <h4 className="entry-title">{entry.title}</h4>
                    <button
                        className={`highlight-btn ${entry.isHighlight ? 'active' : ''}`}
                        onClick={() => onToggleHighlight(entry.id)}
                        title={entry.isHighlight ? 'Highlight verwijderen' : 'Als highlight markeren'}
                    >
                        ⭐
                    </button>
                </div>
                {entry.description && (
                    <p className="entry-description">{entry.description}</p>
                )}
                <div className="entry-meta">
                    <span className="entry-time">{getRelativeTime(entry.timestamp)}</span>
                    {roomName && <span className="entry-room">{roomName}</span>}
                    {entry.monetaryValue && (
                        <span className="entry-amount">{formatCurrency(entry.monetaryValue)}</span>
                    )}
                    {entry.isAutoGenerated && (
                        <span className="entry-auto">⚡ Auto</span>
                    )}
                </div>
            </div>
        </motion.div>
    );
}

// ============================================================================
// NOTES VIEW COMPONENT
// ============================================================================

interface NotesViewProps {
    notes: PlaybookNote[];
    onEdit: (note: PlaybookNote) => void;
    onDelete: (id: string) => Promise<void>;
    onTogglePin: (id: string) => Promise<void>;
    getRoomName: (roomId: string | undefined) => string | null;
}

function NotesView({ notes, onEdit, onDelete, onTogglePin, getRoomName }: NotesViewProps) {
    if (notes.length === 0) {
        return (
            <div className="empty-state">
                <div className="empty-state-icon">📝</div>
                <h2>Nog geen notities</h2>
                <p>
                    Voeg notities toe om belangrijke info, tips, of herinneringen vast te leggen.
                </p>
            </div>
        );
    }

    return (
        <div className="notes-grid">
            <AnimatePresence>
                {notes.map(note => (
                    <motion.div
                        key={note.id}
                        layout
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        exit={{ opacity: 0, scale: 0.9 }}
                        className={`note-card ${note.isPinned ? 'pinned' : ''}`}
                    >
                        <div className="note-header">
                            <h4 className="note-title">{note.title}</h4>
                            <div className="note-actions">
                                <button
                                    className={`pin-btn ${note.isPinned ? 'active' : ''}`}
                                    onClick={() => onTogglePin(note.id)}
                                    title={note.isPinned ? 'Losmaken' : 'Vastzetten'}
                                >
                                    📌
                                </button>
                                <button
                                    className="edit-btn"
                                    onClick={() => onEdit(note)}
                                    title="Bewerken"
                                >
                                    ✏️
                                </button>
                                <button
                                    className="delete-btn"
                                    onClick={() => onDelete(note.id)}
                                    title="Verwijderen"
                                >
                                    🗑️
                                </button>
                            </div>
                        </div>
                        {note.content && (
                            <p className="note-content">{note.content}</p>
                        )}
                        <div className="note-meta">
                            {getRoomName(note.roomId) && (
                                <span className="note-room">{getRoomName(note.roomId)}</span>
                            )}
                            {note.tags.length > 0 && (
                                <div className="note-tags">
                                    {note.tags.map(tag => (
                                        <span key={tag} className="note-tag">#{tag}</span>
                                    ))}
                                </div>
                            )}
                        </div>
                        <div className="note-footer">
                            <span className="note-date">{getRelativeTime(note.updatedAt)}</span>
                        </div>
                    </motion.div>
                ))}
            </AnimatePresence>
        </div>
    );
}
