// Onboarding / Project Setup view
import { useState } from 'react';
import { useProjectStore } from '../../stores';
import type { Address } from '../../domain/project';
import { lookupAddress, isPostcodeApiConfigured } from '../../api/postcodeApi';
import './onboarding.css';

interface OnboardingProps {
    onComplete: () => void;
}

export function Onboarding({ onComplete }: OnboardingProps) {
    const { createProject, addUser } = useProjectStore();

    const [step, setStep] = useState(1);
    const [isLoading, setIsLoading] = useState(false);

    // Project data
    const [projectName, setProjectName] = useState('Onze Verhuizing');
    const [movingDate, setMovingDate] = useState('');

    // Address
    const [postcode, setPostcode] = useState('');
    const [houseNumber, setHouseNumber] = useState('');
    const [street, setStreet] = useState('');
    const [city, setCity] = useState('');
    const [addressLookedUp, setAddressLookedUp] = useState(false);

    // Users
    const [user1Name, setUser1Name] = useState('');
    const [user2Name, setUser2Name] = useState('');

    // Lookup address from postcode
    const handleAddressLookup = async () => {
        if (!postcode || !houseNumber) return;

        setIsLoading(true);
        const address = await lookupAddress(postcode, houseNumber);
        setIsLoading(false);

        if (address) {
            setStreet(address.street);
            setCity(address.city);
            setAddressLookedUp(true);
        }
    };

    // Submit project
    const handleSubmit = async () => {
        if (!movingDate || !user1Name) return;

        setIsLoading(true);

        const address: Address = {
            street: street || 'Onbekend',
            houseNumber,
            postalCode: postcode,
            city: city || 'Onbekend',
        };

        // Create project
        await createProject(projectName, new Date(movingDate), address);

        // Add users
        await addUser(user1Name, '#3b82f6');
        if (user2Name) {
            await addUser(user2Name, '#ef4444');
        }

        setIsLoading(false);
        onComplete();
    };

    return (
        <div className="onboarding">
            <div className="onboarding-card">
                <div className="onboarding-header">
                    <span className="onboarding-logo">🏠</span>
                    <h1>Verhuistool</h1>
                    <p>Laten we je verhuizing plannen!</p>
                </div>

                {/* Step 1: Project info */}
                {step === 1 && (
                    <div className="onboarding-step">
                        <h2>Stap 1: Basisgegevens</h2>

                        <div className="form-group">
                            <label className="form-label">Naam van je verhuizing</label>
                            <input
                                type="text"
                                className="form-input"
                                value={projectName}
                                onChange={e => setProjectName(e.target.value)}
                                placeholder="bijv. Verhuizing Amsterdam"
                            />
                        </div>

                        <div className="form-group">
                            <label className="form-label">Verhuisdatum *</label>
                            <input
                                type="date"
                                className="form-input"
                                value={movingDate}
                                onChange={e => setMovingDate(e.target.value)}
                                required
                            />
                        </div>

                        <button
                            className="btn btn-primary btn-lg full-width"
                            onClick={() => setStep(2)}
                            disabled={!movingDate}
                        >
                            Volgende →
                        </button>
                    </div>
                )}

                {/* Step 2: Address */}
                {step === 2 && (
                    <div className="onboarding-step">
                        <h2>Stap 2: Nieuw adres</h2>

                        <div className="form-row">
                            <div className="form-group">
                                <label className="form-label">Postcode</label>
                                <input
                                    type="text"
                                    className="form-input"
                                    value={postcode}
                                    onChange={e => { setPostcode(e.target.value); setAddressLookedUp(false); }}
                                    placeholder="1234 AB"
                                />
                            </div>
                            <div className="form-group">
                                <label className="form-label">Huisnummer</label>
                                <input
                                    type="text"
                                    className="form-input"
                                    value={houseNumber}
                                    onChange={e => { setHouseNumber(e.target.value); setAddressLookedUp(false); }}
                                    placeholder="123"
                                />
                            </div>
                            {isPostcodeApiConfigured() && (
                                <button
                                    className="btn btn-secondary lookup-btn"
                                    onClick={handleAddressLookup}
                                    disabled={isLoading || !postcode || !houseNumber}
                                >
                                    {isLoading ? '...' : '🔍'}
                                </button>
                            )}
                        </div>

                        <div className="form-group">
                            <label className="form-label">Straat</label>
                            <input
                                type="text"
                                className="form-input"
                                value={street}
                                onChange={e => setStreet(e.target.value)}
                                placeholder="Hoofdstraat"
                                disabled={addressLookedUp}
                            />
                        </div>

                        <div className="form-group">
                            <label className="form-label">Stad</label>
                            <input
                                type="text"
                                className="form-input"
                                value={city}
                                onChange={e => setCity(e.target.value)}
                                placeholder="Amsterdam"
                                disabled={addressLookedUp}
                            />
                        </div>

                        <div className="step-buttons">
                            <button className="btn btn-secondary" onClick={() => setStep(1)}>
                                ← Terug
                            </button>
                            <button
                                className="btn btn-primary"
                                onClick={() => setStep(3)}
                            >
                                Volgende →
                            </button>
                        </div>
                    </div>
                )}

                {/* Step 3: Users */}
                {step === 3 && (
                    <div className="onboarding-step">
                        <h2>Stap 3: Huisgenoten</h2>
                        <p className="step-desc">Wie gaan er verhuizen?</p>

                        <div className="form-group">
                            <label className="form-label">Jouw naam *</label>
                            <input
                                type="text"
                                className="form-input"
                                value={user1Name}
                                onChange={e => setUser1Name(e.target.value)}
                                placeholder="Julian"
                                required
                            />
                        </div>

                        <div className="form-group">
                            <label className="form-label">Huisgenoot (optioneel)</label>
                            <input
                                type="text"
                                className="form-input"
                                value={user2Name}
                                onChange={e => setUser2Name(e.target.value)}
                                placeholder="Pieter"
                            />
                        </div>

                        <div className="step-buttons">
                            <button className="btn btn-secondary" onClick={() => setStep(2)}>
                                ← Terug
                            </button>
                            <button
                                className="btn btn-primary"
                                onClick={handleSubmit}
                                disabled={!user1Name || isLoading}
                            >
                                {isLoading ? 'Bezig...' : '🎉 Start verhuizing!'}
                            </button>
                        </div>
                    </div>
                )}

                {/* Progress dots */}
                <div className="progress-dots">
                    {[1, 2, 3].map(s => (
                        <span
                            key={s}
                            className={`dot ${s === step ? 'active' : ''} ${s < step ? 'completed' : ''}`}
                        />
                    ))}
                </div>
            </div>
        </div>
    );
}
