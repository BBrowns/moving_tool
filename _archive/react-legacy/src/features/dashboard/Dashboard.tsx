// Dashboard view - Overview of moving progress
import { useState, useMemo } from 'react';
import { useProjectStore, useTaskStore, usePackingStore, useShoppingStore, useCostStore, usePlaybookStore, getUpcomingTasks } from '../../stores';
import { formatCurrency, getRoomBudgetSummary, getTotalBudgetStats } from '../../domain/cost';
import { ROOM_TYPE_LABELS } from '../../domain/packing';
import { getRelativeTime, JOURNAL_EVENT_LABELS } from '../../domain/playbook';
import './dashboard.css';

export function Dashboard() {
    const { project, users } = useProjectStore();
    const { tasks } = useTaskStore();
    const { rooms, boxes } = usePackingStore();
    const { items } = useShoppingStore();
    const { expenses, settlements } = useCostStore();
    const { journalEntries } = usePlaybookStore();

    // Calculate stats
    const completedTasks = tasks.filter(t => t.status === 'done').length;
    const totalTasks = tasks.length;
    const taskProgress = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

    const upcomingTasks = getUpcomingTasks(tasks, 3);
    const itemsNeeded = items.filter(i => i.status === 'needed').length;

    // Budget stats
    const budgetStats = useMemo(() =>
        getTotalBudgetStats(rooms, expenses),
        [rooms, expenses]
    );

    // Room budget summaries (only rooms with budgets)
    const roomBudgets = useMemo(() =>
        rooms
            .filter(r => r.budget?.allocated)
            .map(room => ({
                room,
                summary: getRoomBudgetSummary(room.id, room.budget?.allocated, expenses),
            }))
            .sort((a, b) => b.summary.spent - a.summary.spent), // Sort by most spent first
        [rooms, expenses]
    );

    // Recent activity (last 5 entries)
    const recentActivity = useMemo(() =>
        journalEntries.slice(0, 5),
        [journalEntries]
    );

    // Days until move
    const [now] = useState(() => Date.now());

    let daysUntilMove: number | null = null;
    if (project?.movingDate) {
        const dateVal = new Date(project.movingDate);
        if (!isNaN(dateVal.getTime()) && dateVal.getFullYear() > 2000 && dateVal.getFullYear() < 3000) {
            const target = new Date(dateVal);
            target.setHours(0, 0, 0, 0);
            const current = new Date(now);
            current.setHours(0, 0, 0, 0);
            const diffTime = target.getTime() - current.getTime();
            daysUntilMove = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
        }
    }

    return (
        <div className="dashboard">
            <header className="page-header">
                <h1 className="page-title">Dashboard</h1>
                {daysUntilMove !== null && (
                    <div className="countdown-badge">
                        {daysUntilMove > 0
                            ? `📅 Nog ${daysUntilMove} dagen tot verhuisdag`
                            : daysUntilMove === 0
                                ? '🎉 Vandaag is de grote dag!'
                                : `✅ ${Math.abs(daysUntilMove)} dagen geleden verhuisd`
                        }
                    </div>
                )}
            </header>

            {/* Stats */}
            <div className="stats-grid">
                <div className="stat-card">
                    <div className="stat-icon">✅</div>
                    <div className="stat-value">{completedTasks}/{totalTasks}</div>
                    <div className="stat-label">Taken afgerond</div>
                    <div className="progress" style={{ marginTop: '8px' }}>
                        <div className="progress-bar success" style={{ width: `${taskProgress}%` }}></div>
                    </div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon">📦</div>
                    <div className="stat-value">{boxes.length}</div>
                    <div className="stat-label">Dozen ingepakt</div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon">🛒</div>
                    <div className="stat-value">{itemsNeeded}</div>
                    <div className="stat-label">Items nodig</div>
                </div>

                <div className="stat-card">
                    <div className="stat-icon">💰</div>
                    <div className="stat-value">{formatCurrency(budgetStats.totalSpent)}</div>
                    <div className="stat-label">Uitgegeven</div>
                    {budgetStats.totalAllocated > 0 && (
                        <div className="stat-sub">
                            van {formatCurrency(budgetStats.totalAllocated)}
                        </div>
                    )}
                </div>
            </div>

            <div className="dashboard-grid">
                {/* Urgent tasks */}
                <section className="card">
                    <div className="card-header">
                        <h2 className="card-title">⚡ Dringende taken</h2>
                    </div>
                    <div className="card-body">
                        {upcomingTasks.length === 0 ? (
                            <p className="empty-message">Geen dringende taken!</p>
                        ) : (
                            <ul className="task-list-compact">
                                {upcomingTasks.slice(0, 5).map(task => {
                                    const assignee = users.find(u => u.id === task.assigneeId);
                                    return (
                                        <li key={task.id} className="task-item-compact">
                                            <span className={`task-status-dot ${task.status}`}></span>
                                            <span className="task-title">{task.title}</span>
                                            {assignee && (
                                                <span
                                                    className="task-assignee"
                                                    style={{ backgroundColor: assignee.color }}
                                                >
                                                    {assignee.name.charAt(0)}
                                                </span>
                                            )}
                                            {task.deadline && (
                                                <span className="task-deadline">
                                                    {new Date(task.deadline).toLocaleDateString('nl-NL', { day: 'numeric', month: 'short' })}
                                                </span>
                                            )}
                                        </li>
                                    );
                                })}
                            </ul>
                        )}
                    </div>
                </section>

                {/* Room Budgets */}
                <section className="card">
                    <div className="card-header">
                        <h2 className="card-title">🏠 Kamerbudgetten</h2>
                    </div>
                    <div className="card-body">
                        {roomBudgets.length === 0 ? (
                            <p className="empty-message">Geen budgetten ingesteld</p>
                        ) : (
                            <ul className="budget-list">
                                {roomBudgets.slice(0, 4).map(({ room, summary }) => {
                                    const typeInfo = ROOM_TYPE_LABELS[room.roomType];
                                    const percentage = summary.allocated > 0
                                        ? Math.min(100, Math.round((summary.spent / summary.allocated) * 100))
                                        : 0;
                                    return (
                                        <li key={room.id} className="budget-item">
                                            <div className="budget-header">
                                                <span className="budget-room">
                                                    {typeInfo?.emoji || '📦'} {room.name}
                                                </span>
                                                <span className={`budget-amount ${summary.isOverBudget ? 'over' : ''}`}>
                                                    {formatCurrency(summary.spent)} / {formatCurrency(summary.allocated)}
                                                </span>
                                            </div>
                                            <div className="progress budget-progress">
                                                <div
                                                    className={`progress-bar ${summary.isOverBudget ? 'danger' : 'primary'}`}
                                                    style={{ width: `${percentage}%` }}
                                                ></div>
                                            </div>
                                        </li>
                                    );
                                })}
                            </ul>
                        )}
                    </div>
                </section>

                {/* Recent Activity */}
                <section className="card">
                    <div className="card-header">
                        <h2 className="card-title">📓 Recente activiteit</h2>
                    </div>
                    <div className="card-body">
                        {recentActivity.length === 0 ? (
                            <p className="empty-message">Nog geen activiteit</p>
                        ) : (
                            <ul className="activity-list">
                                {recentActivity.map(entry => {
                                    const eventInfo = JOURNAL_EVENT_LABELS[entry.eventType];
                                    return (
                                        <li key={entry.id} className="activity-item">
                                            <span className="activity-icon">{eventInfo.emoji}</span>
                                            <div className="activity-content">
                                                <span className="activity-title">{entry.title}</span>
                                                <span className="activity-time">{getRelativeTime(entry.timestamp)}</span>
                                            </div>
                                            {entry.monetaryValue && (
                                                <span className="activity-amount">{formatCurrency(entry.monetaryValue)}</span>
                                            )}
                                        </li>
                                    );
                                })}
                            </ul>
                        )}
                    </div>
                </section>

                {/* Settlements */}
                <section className="card">
                    <div className="card-header">
                        <h2 className="card-title">💰 Te verrekenen</h2>
                    </div>
                    <div className="card-body">
                        {settlements.length === 0 ? (
                            <p className="empty-message">Alles is verrekend!</p>
                        ) : (
                            <ul className="settlement-list">
                                {settlements.map((settlement, idx) => {
                                    const fromUser = users.find(u => u.id === settlement.fromUserId);
                                    const toUser = users.find(u => u.id === settlement.toUserId);
                                    return (
                                        <li key={idx} className="settlement-item">
                                            <span
                                                className="user-badge"
                                                style={{ backgroundColor: fromUser?.color }}
                                            >
                                                {fromUser?.name}
                                            </span>
                                            <span className="settlement-arrow">→</span>
                                            <span
                                                className="user-badge"
                                                style={{ backgroundColor: toUser?.color }}
                                            >
                                                {toUser?.name}
                                            </span>
                                            <span className="settlement-amount">
                                                {formatCurrency(settlement.amount)}
                                            </span>
                                        </li>
                                    );
                                })}
                            </ul>
                        )}
                    </div>
                </section>
            </div>
        </div>
    );
}

