import { useEffect } from 'react';
import { useProjectStore } from '../../stores';
import './projects.css';

interface ProjectOverviewProps {
    onCreateNew: () => void;
    onSelectProject: (id: string) => void;
}

export function ProjectOverview({ onCreateNew, onSelectProject }: ProjectOverviewProps) {
    const { projects, loadProjects } = useProjectStore();

    useEffect(() => {
        loadProjects();
    }, [loadProjects]);

    return (
        <div className="project-overview-container">
            <header className="overview-header">
                <span className="overview-logo">📦</span>
                <h1>Mijn Verhuizingen</h1>
                <p>Selecteer een verhuizing of start een nieuwe</p>
            </header>

            <div className="projects-grid">
                {projects.map(project => (
                    <div
                        key={project.id}
                        className="project-card"
                        onClick={() => onSelectProject(project.id)}
                    >
                        <div className="project-card-header">
                            <h3 className="project-name">{project.name}</h3>
                            <div className="project-date">
                                📅 {new Date(project.movingDate).toLocaleDateString('nl-NL')}
                            </div>
                        </div>

                        {project.newAddress && (
                            <div className="project-address">
                                📍 {project.newAddress.city}
                            </div>
                        )}
                    </div>
                ))}

                <div className="project-card new-project-card" onClick={onCreateNew}>
                    <div className="new-project-content">
                        <span className="plus-icon">+</span>
                        <span>Nieuwe verhuizing</span>
                    </div>
                </div>
            </div>
        </div>
    );
}
