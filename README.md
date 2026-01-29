# Moving Tool - Verhuistool

Een persoonlijke verhuis-tool voor twee huisgenoten: taken beheren, inpakken organiseren, shopping bijhouden en kosten verdelen.

![Status](https://img.shields.io/badge/status-MVP-green)
![License](https://img.shields.io/badge/license-MIT-blue)

## ✨ Features

### MVP (Volledig)
- **📊 Dashboard** - Overzicht van taken, dozen, shopping en kosten
- **✅ Taken** - Checklist met categorieën, deadlines en toewijzing
- **📦 Inpakken** - Kamers en dozen beheren met QR-code labels
- **🛒 Shopping** - Boodschappenlijst met Marktplaats integratie
- **💰 Kosten** - Uitgaven bijhouden en automatisch verrekenen
- **📄 Export** - CSV export, iCal kalender, email templates

### Automatisering
- 🔍 **Adres lookup** - Automatisch invullen via PostcodeAPI.nu
- 🏷️ **QR Labels** - Printbare labels voor dozen
- 📅 **Kalender sync** - Export naar Google/Apple Calendar
- 📧 **Email templates** - Vooringevulde emails voor nutsvoorzieningen
- ⚡ **Slimme taken** - 25+ taken automatisch gegenereerd

## 🛠️ Tech Stack

| Laag | Technologie |
|------|-------------|
| Framework | React 18 + TypeScript |
| Bundler | Vite |
| State | Zustand |
| Database | IndexedDB (Dexie.js) |
| Styling | Vanilla CSS + CSS Variables |
| PWA | vite-plugin-pwa |

## 📦 Installatie

```bash
# Clone repository
git clone https://github.com/[username]/moving-tool.git
cd moving-tool

# Installeer dependencies
npm install

# Start development server
npm run dev
```

De app draait nu op `http://localhost:5173`

## 🔧 Configuratie

### PostcodeAPI (optioneel)

Voor automatische adres lookup, maak een gratis account aan op [postcodeapi.nu](https://www.postcodeapi.nu) en voeg je API key toe:

```bash
# Maak .env.local aan
echo "VITE_POSTCODE_API_KEY=your_api_key_here" > .env.local
```

## 📁 Project Structuur

```
src/
├── domain/          # TypeScript types (pure)
├── db/              # IndexedDB (Dexie)
├── stores/          # Zustand state management
├── api/             # Externe API integraties
├── templates/       # Taak & email templates
├── components/      # Shared UI components
├── features/        # Feature modules
│   ├── dashboard/
│   ├── tasks/
│   ├── packing/
│   ├── shopping/
│   ├── costs/
│   ├── export/
│   └── onboarding/
└── utils/           # Helper functions
```

## 🚀 Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run preview  # Preview production build
npm run lint     # Run ESLint
```

## 📋 Roadmap

### Nice-to-have
- [ ] QR-code scanner voor dozen
- [ ] Room planner (eenvoudig)
- [ ] Marktplaats watchlist notificaties

### Toekomst
- [ ] Cloud sync (Firebase/Supabase)
- [ ] Mobiele companion app
- [ ] Smart reminders
- [ ] Automatische suggesties

## 🤝 Contributing

Dit is een persoonlijk project, maar suggesties zijn welkom via issues.

## 📄 License

MIT
