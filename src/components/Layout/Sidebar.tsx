// Sidebar navigation component
import { useState } from 'react';
import { useProjectStore, useTaskStore } from '../../stores';
import { ThemeToggle } from '../common/ThemeToggle';

interface NavItem {
    path: string;
    icon: string;
    label: string;
    badge?: number;
}

interface SidebarProps {
    activePath?: string;
    onNavigate?: (path: string) => void;
}

export function Sidebar({ activePath = 'dashboard', onNavigate }: SidebarProps) {
    const { project } = useProjectStore();
    const { tasks } = useTaskStore();

    // Calculate badges
    const todoTasks = tasks.filter(t => t.status === 'todo');

    const navItems: NavItem[] = [
        { path: 'dashboard', icon: '📊', label: 'Dashboard' },
        { path: 'tasks', icon: '✅', label: 'Taken', badge: todoTasks.length || undefined },
        { path: 'packing', icon: '📦', label: 'Inpakken' },
        { path: 'shopping', icon: '🛒', label: 'Shopping' },
        { path: 'costs', icon: '💰', label: 'Kosten' },
    ];

    const toolItems: NavItem[] = [
        { path: 'emails', icon: '📧', label: 'Email Templates' },
        { path: 'export', icon: '📄', label: 'Export' },
    ];

    // Calculate days until moving
    const [now] = useState(() => Date.now());
    const daysUntilMove = project?.movingDate
        ? Math.ceil((new Date(project.movingDate).getTime() - now) / (1000 * 60 * 60 * 24))
        : null;

    const handleClick = (path: string) => {
        if (onNavigate) {
            onNavigate(path);
        }
    };

    return (
        <aside className="sidebar">
            <div className="sidebar-header">
                <div className="sidebar-logo">
                    <span className="sidebar-logo-icon">🏠</span>
                    <span>Verhuistool</span>
                </div>
                <ThemeToggle />
            </div>

            <nav className="sidebar-nav">
                <div className="nav-section">
                    <div className="nav-section-title">Overzicht</div>
                    {navItems.map(item => (
                        <a
                            key={item.path}
                            href={`#${item.path}`}
                            className={`nav-link ${activePath === item.path ? 'active' : ''}`}
                            onClick={(e) => {
                                e.preventDefault();
                                handleClick(item.path);
                            }}
                        >
                            <span className="nav-link-icon">{item.icon}</span>
                            <span>{item.label}</span>
                            {item.badge && item.badge > 0 && (
                                <span className="nav-link-badge">{item.badge}</span>
                            )}
                        </a>
                    ))}
                </div>

                <div className="nav-section">
                    <div className="nav-section-title">Tools</div>
                    {toolItems.map(item => (
                        <a
                            key={item.path}
                            href={`#${item.path}`}
                            className={`nav-link ${activePath === item.path ? 'active' : ''}`}
                            onClick={(e) => {
                                e.preventDefault();
                                handleClick(item.path);
                            }}
                        >
                            <span className="nav-link-icon">{item.icon}</span>
                            <span>{item.label}</span>
                        </a>
                    ))}

                    <a
                        href="#settings"
                        className={`nav-link ${activePath === 'settings' ? 'active' : ''}`}
                        onClick={(e) => {
                            e.preventDefault();
                            handleClick('settings');
                        }}
                    >
                        <span className="nav-link-icon">⚙️</span>
                        <span>Instellingen</span>
                    </a>
                </div>
            </nav>

            {project && (
                <div className="sidebar-project">
                    <div className="sidebar-project-name">{project.name}</div>
                    <div className="sidebar-project-date">
                        <span>📅</span>
                        {daysUntilMove !== null && (
                            <span className="sidebar-project-countdown">
                                {daysUntilMove > 0
                                    ? `Nog ${daysUntilMove} dagen`
                                    : daysUntilMove === 0
                                        ? 'Vandaag!'
                                        : `${Math.abs(daysUntilMove)} dagen geleden`
                                }
                            </span>
                        )}
                    </div>

                    <button
                        className="switch-project-btn"
                        onClick={() => handleClick('projects')}
                    >
                        <span>🔀</span> Wissel verhuizing
                    </button>
                </div>
            )}
        </aside>
    );
}
