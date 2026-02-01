// Main App component - routing and initialization
import { useState, useEffect } from 'react';
import { useProjectStore, useTaskStore, usePackingStore, useShoppingStore, useCostStore, usePlaybookStore } from './stores';

// Components
import { Layout } from './components/Layout/Layout';
import { Onboarding } from './features/onboarding/Onboarding';
import { Dashboard } from './features/dashboard/Dashboard';
import { TasksView } from './features/tasks/TasksView';
import { PackingView } from './features/packing/PackingView';
import { ShoppingView } from './features/shopping/ShoppingView';
import { CostsView } from './features/costs/CostsView';
import { ProjectOverview } from './features/projects/ProjectOverview';
import { SettingsView } from './features/settings/SettingsView';
import { ExportView } from './features/export/ExportView';
import { PlaybookView } from './features/playbook/PlaybookView';

// Styles
import './index.css';
import './components/common/common.css';

type View = 'dashboard' | 'tasks' | 'packing' | 'shopping' | 'costs' | 'playbook' | 'emails' | 'export' | 'settings' | 'projects' | 'onboarding';

function App() {
  const { project, users, projects, isLoading: projectLoading, loadProjects, loadProject, setActiveProject, clearActiveProject } = useProjectStore();
  const { loadTasks } = useTaskStore();
  const { loadPacking } = usePackingStore();
  const { loadItems } = useShoppingStore();
  const { loadExpenses } = useCostStore();
  const { loadPlaybook } = usePlaybookStore();

  const [currentView, setCurrentView] = useState<View>('dashboard');
  const [isInitialized, setIsInitialized] = useState(false);

  // Load projects on mount
  useEffect(() => {
    loadProjects().then(() => {
      // Try to load last active project or just init
      loadProject().then(() => setIsInitialized(true));
    });
  }, [loadProjects, loadProject]);

  // Load all data when project is available
  useEffect(() => {
    if (project) {
      loadTasks(project.id);
      loadPacking(project.id);
      loadItems(project.id);
      loadExpenses(project.id, users.map(u => u.id));
      loadPlaybook(project.id);
    }
  }, [project, users, loadTasks, loadPacking, loadItems, loadExpenses]);

  // Handle navigation from sidebar
  const handleNavigate = (path: string) => {
    setCurrentView(path as View);
  };

  // Show loading state
  if (!isInitialized || projectLoading) {
    return (
      <div className="loading-screen">
        <div className="spinner"></div>
        <p>Laden...</p>
      </div>
    );
  }

  // Show onboarding if no projects exist or explicitly requested
  if (projects.length === 0 || currentView === 'onboarding') {
    return (
      <Onboarding
        onComplete={async () => {
          // After project creation, reload projects and set view to dashboard
          await loadProjects();
          await loadProject();
          setCurrentView('dashboard');
        }}
      />
    );
  }

  // Show Project Overview if no project selected or explicitly requested
  if (!project || currentView === 'projects') {
    return (
      <ProjectOverview
        onCreateNew={() => {
          clearActiveProject();
          setCurrentView('onboarding');
        }}
        onSelectProject={(id) => {
          setActiveProject(id).then(() => setCurrentView('dashboard'));
        }}
      />
    );
  }

  // Render current view
  const renderView = () => {
    switch (currentView) {
      case 'dashboard':
        return <Dashboard />;
      case 'tasks':
        return <TasksView />;
      case 'packing':
        return <PackingView />;
      case 'shopping':
        return <ShoppingView />;
      case 'costs':
        return <CostsView />;
      case 'playbook':
        return <PlaybookView />;
      case 'settings':
        return <SettingsView />;
      case 'emails':
      case 'export':
        return <ExportView />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <Layout activePath={currentView} onNavigate={handleNavigate}>
      {renderView()}
    </Layout>
  );
}

export default App;
