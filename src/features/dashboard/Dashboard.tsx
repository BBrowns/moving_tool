// Dashboard view - Overview of moving progress
import { useProjectStore, useTaskStore, usePackingStore, useShoppingStore, useCostStore, getUpcomingTasks } from '../../stores';
import { formatCurrency } from '../../domain/cost';
import './dashboard.css';

export function Dashboard() {
    const { project, users } = useProjectStore();
    const { tasks } = useTaskStore();
    const { rooms, boxes } = usePackingStore();
    const { items } = useShoppingStore();
    const { settlements } = useCostStore();

    // Calculate stats
    const completedTasks = tasks.filter(t => t.status === 'done').length;
    const totalTasks = tasks.length;
    const taskProgress = totalTasks > 0 ? Math.round((completedTasks / totalTasks) * 100) : 0;

    const upcomingTasks = getUpcomingTasks(tasks, 3);
    const itemsNeeded = items.filter(i => i.status === 'needed').length;

    // Days until move
    const daysUntilMove = project?.movingDate
        ? Math.ceil((new Date(project.movingDate).getTime() - Date.now()) / (1000 * 60 * 60 * 24))
        : null;

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
                    <div className="stat-icon">🏠</div>
                    <div className="stat-value">{rooms.length}</div>
                    <div className="stat-label">Kamers</div>
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
