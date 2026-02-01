// Shopping view - Shopping list with Marktplaats integration
import { useState } from 'react';
import { useProjectStore, useShoppingStore, getFilteredItems, getShoppingStats } from '../../stores';
import { SHOPPING_CATEGORY_LABELS, SHOPPING_STATUS_LABELS, type ShoppingItem, type ShoppingCategory, type ShoppingStatus, type AcquisitionType } from '../../domain/shopping';
import { formatCurrency, parseCurrency } from '../../domain/cost';
import { Modal } from '../../components/common/Modal';
import { openMarktplaatsSearch } from '../../api/marktplaatsSearch';
import { NegotiationKanban } from './NegotiationKanban';
import './shopping.css';

type ViewMode = 'list' | 'marketplace';

export function ShoppingView() {
    const { project } = useProjectStore();
    const { items, addItem, updateItem, deleteItem, setItemStatus, addSavedLink, filters, setFilters, clearFilters } = useShoppingStore();

    const [viewMode, setViewMode] = useState<ViewMode>('list');
    const [showAddModal, setShowAddModal] = useState(false);
    const [editingItem, setEditingItem] = useState<ShoppingItem | null>(null);
    const [showLinkModal, setShowLinkModal] = useState(false);
    const [newLink, setNewLink] = useState({ url: '', title: '', price: '' });

    const [formData, setFormData] = useState({
        name: '',
        category: 'overig' as ShoppingCategory,
        acquisitionType: 'retail' as AcquisitionType,
        maxPrice: '',
        notes: '',
        sellerName: '',
        sellerLocation: '',
        askingPrice: '',
    });

    // Filter retail items for list view (marketplace items go to Kanban)
    const retailItems = items.filter(item => item.acquisitionType !== 'marketplace');
    const filteredItems = getFilteredItems(retailItems, filters);
    const stats = getShoppingStats(items);
    const marketplaceCount = items.filter(i => i.acquisitionType === 'marketplace').length;

    // Group by status
    const itemsByStatus: Record<ShoppingStatus, ShoppingItem[]> = {
        needed: filteredItems.filter(i => i.status === 'needed'),
        found: filteredItems.filter(i => i.status === 'found'),
        bought: filteredItems.filter(i => i.status === 'bought'),
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!project) return;

        const baseData = {
            projectId: project.id,
            name: formData.name,
            category: formData.category,
            status: 'needed' as const,
            acquisitionType: formData.acquisitionType,
            maxPrice: formData.maxPrice ? parseCurrency(formData.maxPrice) : undefined,
            notes: formData.notes || undefined,
        };

        // Add marketplace-specific data if applicable
        const itemData = formData.acquisitionType === 'marketplace'
            ? {
                ...baseData,
                marketplace: {
                    platform: 'marktplaats' as const,
                    negotiationStatus: 'watching' as const,
                    sellerName: formData.sellerName || undefined,
                    sellerLocation: formData.sellerLocation || undefined,
                    askingPrice: formData.askingPrice ? parseCurrency(formData.askingPrice) : undefined,
                    pickupCompleted: false,
                }
            }
            : baseData;

        if (editingItem) {
            await updateItem(editingItem.id, itemData);
        } else {
            await addItem(itemData);
        }

        resetForm();
    };

    const resetForm = () => {
        setFormData({
            name: '',
            category: 'overig',
            acquisitionType: 'retail',
            maxPrice: '',
            notes: '',
            sellerName: '',
            sellerLocation: '',
            askingPrice: '',
        });
        setShowAddModal(false);
        setEditingItem(null);
    };

    const handleAddLink = async () => {
        if (!editingItem || !newLink.url) return;
        await addSavedLink(editingItem.id, {
            url: newLink.url,
            title: newLink.title || newLink.url,
            price: newLink.price ? parseCurrency(newLink.price) : undefined,
        });
        setNewLink({ url: '', title: '', price: '' });
        setShowLinkModal(false);
    };

    return (
        <div className="shopping-view">
            <header className="page-header">
                <h1 className="page-title">Shopping</h1>
                <div className="page-actions">
                    <button className="btn btn-primary" onClick={() => setShowAddModal(true)}>
                        + Nieuw item
                    </button>
                </div>
            </header>

            {/* View Mode Toggle */}
            <div className="view-toggle" style={{ marginBottom: 'var(--space-6)' }}>
                <button
                    className={`view-toggle-btn ${viewMode === 'list' ? 'active' : ''}`}
                    onClick={() => setViewMode('list')}
                >
                    🏪 Winkellijst
                </button>
                <button
                    className={`view-toggle-btn ${viewMode === 'marketplace' ? 'active' : ''}`}
                    onClick={() => setViewMode('marketplace')}
                >
                    🛒 Marktplaats
                    {marketplaceCount > 0 && (
                        <span style={{
                            marginLeft: '0.5rem',
                            background: 'var(--color-primary)',
                            color: 'white',
                            padding: '2px 8px',
                            borderRadius: 'var(--radius-full)',
                            fontSize: 'var(--text-xs)'
                        }}>
                            {marketplaceCount}
                        </span>
                    )}
                </button>
            </div>

            {/* Marketplace Kanban View */}
            {viewMode === 'marketplace' && <NegotiationKanban />}

            {/* Regular Shopping List View */}
            {viewMode === 'list' && (
                <>
                    {/* Stats */}
                    <div className="shopping-stats">
                        <div className="stat-pill needed">
                            <span className="stat-count">{stats.needed}</span>
                            <span>Nodig</span>
                        </div>
                        <div className="stat-pill found">
                            <span className="stat-count">{stats.found}</span>
                            <span>Gevonden</span>
                        </div>
                        <div className="stat-pill bought">
                            <span className="stat-count">{stats.bought}</span>
                            <span>Gekocht</span>
                        </div>
                        {stats.totalBudget > 0 && (
                            <div className="stat-pill budget">
                                <span className="stat-count">{formatCurrency(stats.totalSpent)}</span>
                                <span>/ {formatCurrency(stats.totalBudget)}</span>
                            </div>
                        )}
                    </div>

                    {/* Filters */}
                    <div className="shopping-filters">
                        <select
                            className="form-input form-select"
                            value={filters.status || ''}
                            onChange={e => setFilters({ status: e.target.value as ShoppingStatus || undefined })}
                        >
                            <option value="">Alle statussen</option>
                            {Object.entries(SHOPPING_STATUS_LABELS).map(([value, { label }]) => (
                                <option key={value} value={value}>{label}</option>
                            ))}
                        </select>

                        <select
                            className="form-input form-select"
                            value={filters.category || ''}
                            onChange={e => setFilters({ category: e.target.value as ShoppingCategory || undefined })}
                        >
                            <option value="">Alle categorieën</option>
                            {Object.entries(SHOPPING_CATEGORY_LABELS).map(([value, { label, emoji }]) => (
                                <option key={value} value={value}>{emoji} {label}</option>
                            ))}
                        </select>

                        {Object.keys(filters).length > 0 && (
                            <button className="btn btn-ghost btn-sm" onClick={clearFilters}>
                                ✕ Reset
                            </button>
                        )}
                    </div>

                    {/* Items by status */}
                    <div className="shopping-columns">
                        {(['needed', 'found', 'bought'] as ShoppingStatus[]).map(status => (
                            <div key={status} className="shopping-column">
                                <h2 className="column-title" style={{ color: SHOPPING_STATUS_LABELS[status].color }}>
                                    {SHOPPING_STATUS_LABELS[status].label}
                                    <span className="column-count">{itemsByStatus[status].length}</span>
                                </h2>

                                <div className="shopping-items">
                                    {itemsByStatus[status].map(item => (
                                        <div key={item.id} className="shopping-card">
                                            <div className="shopping-card-header">
                                                <span className="category-icon">
                                                    {SHOPPING_CATEGORY_LABELS[item.category].emoji}
                                                </span>
                                                <span className="item-name">{item.name}</span>
                                                <button
                                                    className="btn btn-ghost btn-icon btn-sm"
                                                    onClick={() => deleteItem(item.id)}
                                                >
                                                    🗑️
                                                </button>
                                            </div>

                                            {item.maxPrice && (
                                                <div className="price-info">
                                                    Max: {formatCurrency(item.maxPrice)}
                                                    {item.actualPrice && (
                                                        <span className="actual-price">
                                                            → {formatCurrency(item.actualPrice)}
                                                        </span>
                                                    )}
                                                </div>
                                            )}

                                            {item.savedLinks.length > 0 && (
                                                <div className="saved-links">
                                                    {item.savedLinks.map((link, idx) => (
                                                        <a
                                                            key={idx}
                                                            href={link.url}
                                                            target="_blank"
                                                            rel="noopener noreferrer"
                                                            className="saved-link"
                                                        >
                                                            🔗 {link.title}
                                                            {link.price && ` (${formatCurrency(link.price)})`}
                                                        </a>
                                                    ))}
                                                </div>
                                            )}

                                            <div className="shopping-card-actions">
                                                <button
                                                    className="btn btn-secondary btn-sm"
                                                    onClick={() => openMarktplaatsSearch(item, { maxPrice: item.maxPrice })}
                                                >
                                                    🔍 Marktplaats
                                                </button>

                                                {status !== 'bought' && (
                                                    <select
                                                        className="form-input form-select status-select"
                                                        value={item.status}
                                                        onChange={e => setItemStatus(item.id, e.target.value as ShoppingStatus)}
                                                    >
                                                        <option value="needed">Nodig</option>
                                                        <option value="found">Gevonden</option>
                                                        <option value="bought">Gekocht</option>
                                                    </select>
                                                )}

                                                <button
                                                    className="btn btn-ghost btn-sm"
                                                    onClick={() => { setEditingItem(item); setShowLinkModal(true); }}
                                                >
                                                    + Link
                                                </button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </>
            )}

            {/* Add/Edit Modal */}
            <Modal
                isOpen={showAddModal}
                onClose={resetForm}
                title={editingItem ? 'Item bewerken' : 'Nieuw item'}
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={resetForm}>Annuleren</button>
                        <button className="btn btn-primary" onClick={handleSubmit}>
                            {editingItem ? 'Opslaan' : 'Toevoegen'}
                        </button>
                    </>
                }
            >
                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label className="form-label">Type aankoop</label>
                        <select
                            className="form-input form-select"
                            value={formData.acquisitionType}
                            onChange={e => setFormData({ ...formData, acquisitionType: e.target.value as AcquisitionType })}
                        >
                            <option value="retail">🏪 Winkel (IKEA, Action)</option>
                            <option value="marketplace">🛒 Marktplaats</option>
                            <option value="service">📋 Dienst (Energie, Internet)</option>
                            <option value="renovation">🔧 Verbouwing (verf, materialen)</option>
                        </select>
                    </div>

                    <div className="form-group">
                        <label className="form-label">Naam *</label>
                        <input
                            type="text"
                            className="form-input"
                            value={formData.name}
                            onChange={e => setFormData({ ...formData, name: e.target.value })}
                            placeholder="bijv. Eettafel, Staande lamp"
                            required
                            autoFocus
                        />
                    </div>

                    <div className="form-row">
                        <div className="form-group">
                            <label className="form-label">Categorie</label>
                            <select
                                className="form-input form-select"
                                value={formData.category}
                                onChange={e => setFormData({ ...formData, category: e.target.value as ShoppingCategory })}
                            >
                                {Object.entries(SHOPPING_CATEGORY_LABELS).map(([value, { label, emoji }]) => (
                                    <option key={value} value={value}>{emoji} {label}</option>
                                ))}
                            </select>
                        </div>

                        <div className="form-group">
                            <label className="form-label">
                                {formData.acquisitionType === 'marketplace' ? 'Vraagprijs (€)' : 'Max budget (€)'}
                            </label>
                            <input
                                type="number"
                                className="form-input"
                                value={formData.acquisitionType === 'marketplace' ? formData.askingPrice : formData.maxPrice}
                                onChange={e => setFormData({
                                    ...formData,
                                    [formData.acquisitionType === 'marketplace' ? 'askingPrice' : 'maxPrice']: e.target.value
                                })}
                                placeholder="150"
                                min="0"
                                step="1"
                            />
                        </div>
                    </div>

                    {/* Marketplace-specific fields */}
                    {formData.acquisitionType === 'marketplace' && (
                        <div className="form-row">
                            <div className="form-group">
                                <label className="form-label">Verkoper naam</label>
                                <input
                                    type="text"
                                    className="form-input"
                                    value={formData.sellerName}
                                    onChange={e => setFormData({ ...formData, sellerName: e.target.value })}
                                    placeholder="Jan"
                                />
                            </div>
                            <div className="form-group">
                                <label className="form-label">Locatie</label>
                                <input
                                    type="text"
                                    className="form-input"
                                    value={formData.sellerLocation}
                                    onChange={e => setFormData({ ...formData, sellerLocation: e.target.value })}
                                    placeholder="Amsterdam"
                                />
                            </div>
                        </div>
                    )}

                    <div className="form-group">
                        <label className="form-label">Notities</label>
                        <textarea
                            className="form-input form-textarea"
                            value={formData.notes}
                            onChange={e => setFormData({ ...formData, notes: e.target.value })}
                            rows={2}
                        />
                    </div>
                </form>
            </Modal>

            {/* Add Link Modal */}
            <Modal
                isOpen={showLinkModal}
                onClose={() => { setShowLinkModal(false); setNewLink({ url: '', title: '', price: '' }); }}
                title="Link opslaan"
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={() => setShowLinkModal(false)}>Annuleren</button>
                        <button className="btn btn-primary" onClick={handleAddLink}>Opslaan</button>
                    </>
                }
            >
                <div className="form-group">
                    <label className="form-label">URL *</label>
                    <input
                        type="url"
                        className="form-input"
                        value={newLink.url}
                        onChange={e => setNewLink({ ...newLink, url: e.target.value })}
                        placeholder="https://marktplaats.nl/..."
                        required
                    />
                </div>
                <div className="form-row">
                    <div className="form-group">
                        <label className="form-label">Titel</label>
                        <input
                            type="text"
                            className="form-input"
                            value={newLink.title}
                            onChange={e => setNewLink({ ...newLink, title: e.target.value })}
                            placeholder="Eiken tafel 6p"
                        />
                    </div>
                    <div className="form-group">
                        <label className="form-label">Prijs (€)</label>
                        <input
                            type="number"
                            className="form-input"
                            value={newLink.price}
                            onChange={e => setNewLink({ ...newLink, price: e.target.value })}
                            placeholder="150"
                        />
                    </div>
                </div>
            </Modal>
        </div>
    );
}
