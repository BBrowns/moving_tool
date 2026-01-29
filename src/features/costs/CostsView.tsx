// Costs view - Expense tracking and settlements
import { useState } from 'react';
import { useProjectStore, useCostStore, getExpensesByUser, getTotalExpenses } from '../../stores';
import { formatCurrency, parseCurrency, type Expense } from '../../domain/cost';
import { Modal } from '../../components/common/Modal';
import './costs.css';

export function CostsView() {
    const { project, users } = useProjectStore();
    const { expenses, settlements, addExpense, updateExpense, deleteExpense } = useCostStore();

    const [showAddModal, setShowAddModal] = useState(false);
    const [editingExpense, setEditingExpense] = useState<Expense | null>(null);

    const [formData, setFormData] = useState({
        description: '',
        amount: '',
        paidById: users[0]?.id || '',
        splitBetween: users.map(u => u.id),
        category: '',
        date: new Date().toISOString().split('T')[0],
    });

    const totalExpenses = getTotalExpenses(expenses);
    const expensesByUser = getExpensesByUser(expenses);

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!project) return;

        const expenseData = {
            projectId: project.id,
            description: formData.description,
            amount: parseCurrency(formData.amount),
            paidById: formData.paidById,
            splitBetween: formData.splitBetween,
            category: formData.category || undefined,
            date: new Date(formData.date),
        };

        if (editingExpense) {
            await updateExpense(editingExpense.id, expenseData);
        } else {
            await addExpense(expenseData);
        }

        resetForm();
    };

    const resetForm = () => {
        setFormData({
            description: '',
            amount: '',
            paidById: users[0]?.id || '',
            splitBetween: users.map(u => u.id),
            category: '',
            date: new Date().toISOString().split('T')[0],
        });
        setShowAddModal(false);
        setEditingExpense(null);
    };

    const startEdit = (expense: Expense) => {
        setFormData({
            description: expense.description,
            amount: (expense.amount / 100).toString(),
            paidById: expense.paidById,
            splitBetween: expense.splitBetween,
            category: expense.category || '',
            date: new Date(expense.date).toISOString().split('T')[0],
        });
        setEditingExpense(expense);
        setShowAddModal(true);
    };

    const toggleUserInSplit = (userId: string) => {
        const { splitBetween } = formData;
        if (splitBetween.includes(userId)) {
            if (splitBetween.length > 1) {
                setFormData({ ...formData, splitBetween: splitBetween.filter(id => id !== userId) });
            }
        } else {
            setFormData({ ...formData, splitBetween: [...splitBetween, userId] });
        }
    };

    return (
        <div className="costs-view">
            <header className="page-header">
                <h1 className="page-title">Kosten</h1>
                <div className="page-actions">
                    <button className="btn btn-primary" onClick={() => setShowAddModal(true)}>
                        + Nieuwe uitgave
                    </button>
                </div>
            </header>

            {/* Summary */}
            <div className="costs-summary">
                <div className="summary-card total">
                    <div className="summary-label">Totaal uitgegeven</div>
                    <div className="summary-value">{formatCurrency(totalExpenses)}</div>
                </div>

                {users.map(user => (
                    <div key={user.id} className="summary-card" style={{ borderTopColor: user.color }}>
                        <div className="summary-label">{user.name} betaald</div>
                        <div className="summary-value">{formatCurrency(expensesByUser[user.id] || 0)}</div>
                    </div>
                ))}
            </div>

            {/* Settlements */}
            {settlements.length > 0 && (
                <section className="settlements-section">
                    <h2 className="section-title">💰 Te verrekenen</h2>
                    <div className="settlements-list">
                        {settlements.map((settlement, idx) => {
                            const fromUser = users.find(u => u.id === settlement.fromUserId);
                            const toUser = users.find(u => u.id === settlement.toUserId);
                            return (
                                <div key={idx} className="settlement-card">
                                    <span
                                        className="settlement-user from"
                                        style={{ backgroundColor: fromUser?.color }}
                                    >
                                        {fromUser?.name}
                                    </span>
                                    <span className="settlement-arrow">betaalt</span>
                                    <span className="settlement-amount">{formatCurrency(settlement.amount)}</span>
                                    <span className="settlement-arrow">aan</span>
                                    <span
                                        className="settlement-user to"
                                        style={{ backgroundColor: toUser?.color }}
                                    >
                                        {toUser?.name}
                                    </span>
                                </div>
                            );
                        })}
                    </div>
                </section>
            )}

            {/* Expenses list */}
            <section className="expenses-section">
                <h2 className="section-title">📋 Uitgaven ({expenses.length})</h2>

                {expenses.length === 0 ? (
                    <div className="empty-state">
                        <div className="empty-state-icon">💸</div>
                        <div className="empty-state-title">Geen uitgaven</div>
                        <p>Voeg een uitgave toe om te beginnen met bijhouden.</p>
                    </div>
                ) : (
                    <div className="expenses-list">
                        {expenses.map(expense => {
                            const paidBy = users.find(u => u.id === expense.paidById);
                            return (
                                <div key={expense.id} className="expense-card" onClick={() => startEdit(expense)}>
                                    <div className="expense-main">
                                        <div className="expense-description">{expense.description}</div>
                                        <div className="expense-meta">
                                            <span className="expense-date">
                                                {new Date(expense.date).toLocaleDateString('nl-NL')}
                                            </span>
                                            {expense.category && (
                                                <span className="expense-category">{expense.category}</span>
                                            )}
                                        </div>
                                    </div>

                                    <div className="expense-amount">{formatCurrency(expense.amount)}</div>

                                    <div className="expense-paid-by">
                                        <span
                                            className="paid-by-badge"
                                            style={{ backgroundColor: paidBy?.color }}
                                            title={`Betaald door ${paidBy?.name}`}
                                        >
                                            {paidBy?.name.charAt(0)}
                                        </span>
                                    </div>

                                    <button
                                        className="btn btn-ghost btn-icon btn-sm"
                                        onClick={(e) => { e.stopPropagation(); deleteExpense(expense.id); }}
                                    >
                                        🗑️
                                    </button>
                                </div>
                            );
                        })}
                    </div>
                )}
            </section>

            {/* Add/Edit Modal */}
            <Modal
                isOpen={showAddModal}
                onClose={resetForm}
                title={editingExpense ? 'Uitgave bewerken' : 'Nieuwe uitgave'}
                footer={
                    <>
                        <button className="btn btn-secondary" onClick={resetForm}>Annuleren</button>
                        <button className="btn btn-primary" onClick={handleSubmit}>
                            {editingExpense ? 'Opslaan' : 'Toevoegen'}
                        </button>
                    </>
                }
            >
                <form onSubmit={handleSubmit}>
                    <div className="form-group">
                        <label className="form-label">Beschrijving *</label>
                        <input
                            type="text"
                            className="form-input"
                            value={formData.description}
                            onChange={e => setFormData({ ...formData, description: e.target.value })}
                            placeholder="bijv. Verhuiswagen, Dozen"
                            required
                            autoFocus
                        />
                    </div>

                    <div className="form-row">
                        <div className="form-group">
                            <label className="form-label">Bedrag (€) *</label>
                            <input
                                type="number"
                                className="form-input"
                                value={formData.amount}
                                onChange={e => setFormData({ ...formData, amount: e.target.value })}
                                placeholder="150"
                                min="0"
                                step="0.01"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <label className="form-label">Datum</label>
                            <input
                                type="date"
                                className="form-input"
                                value={formData.date}
                                onChange={e => setFormData({ ...formData, date: e.target.value })}
                            />
                        </div>
                    </div>

                    <div className="form-group">
                        <label className="form-label">Betaald door</label>
                        <div className="user-buttons">
                            {users.map(user => (
                                <button
                                    key={user.id}
                                    type="button"
                                    className={`user-button ${formData.paidById === user.id ? 'selected' : ''}`}
                                    style={{
                                        '--user-color': user.color,
                                        borderColor: formData.paidById === user.id ? user.color : undefined,
                                        backgroundColor: formData.paidById === user.id ? `${user.color}20` : undefined,
                                    } as React.CSSProperties}
                                    onClick={() => setFormData({ ...formData, paidById: user.id })}
                                >
                                    {user.name}
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className="form-group">
                        <label className="form-label">Verdelen tussen</label>
                        <div className="user-buttons">
                            {users.map(user => (
                                <button
                                    key={user.id}
                                    type="button"
                                    className={`user-button ${formData.splitBetween.includes(user.id) ? 'selected' : ''}`}
                                    style={{
                                        '--user-color': user.color,
                                        borderColor: formData.splitBetween.includes(user.id) ? user.color : undefined,
                                        backgroundColor: formData.splitBetween.includes(user.id) ? `${user.color}20` : undefined,
                                    } as React.CSSProperties}
                                    onClick={() => toggleUserInSplit(user.id)}
                                >
                                    {user.name}
                                </button>
                            ))}
                        </div>
                    </div>

                    <div className="form-group">
                        <label className="form-label">Categorie</label>
                        <input
                            type="text"
                            className="form-input"
                            value={formData.category}
                            onChange={e => setFormData({ ...formData, category: e.target.value })}
                            placeholder="bijv. Transport, Materiaal"
                        />
                    </div>
                </form>
            </Modal>
        </div>
    );
}
