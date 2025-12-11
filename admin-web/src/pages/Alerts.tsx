import { useState } from 'react';
import { useMutation, useQuery } from '@tanstack/react-query';
import { apiService } from '../services/api';

const LIBERIA_COUNTIES = [
  'Bomi', 'Bong', 'Gbarpolu', 'Grand Bassa', 'Grand Cape Mount',
  'Grand Gedeh', 'Grand Kru', 'Lofa', 'Margibi', 'Maryland',
  'Montserrado', 'Nimba', 'River Cess', 'River Gee', 'Sinoe'
];

export default function Alerts() {
  const [formData, setFormData] = useState({
    message: '',
    severity: 'medium',
    target_counties: [] as string[],
    send_sms: false,
    send_push: true,
  });

  const broadcastMutation = useMutation({
    mutationFn: (data: typeof formData) => apiService.broadcastAlert({
      message: data.message,
      severity: data.severity,
      target_counties: data.target_counties.length > 0 ? data.target_counties : undefined,
      send_sms: data.send_sms,
      send_push: data.send_push,
    }),
    onSuccess: () => {
      alert('Alert broadcast successfully!');
      setFormData({
        message: '',
        severity: 'medium',
        target_counties: [],
        send_sms: false,
        send_push: true,
      });
    },
    onError: (error: any) => {
      alert(`Error: ${error.response?.data?.detail || error.message}`);
    },
  });

  const handleCountyToggle = (county: string) => {
    setFormData(prev => ({
      ...prev,
      target_counties: prev.target_counties.includes(county)
        ? prev.target_counties.filter(c => c !== county)
        : [...prev.target_counties, county],
    }));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.message.trim()) {
      alert('Please enter a message');
      return;
    }
    broadcastMutation.mutate(formData);
  };

  return (
    <div className="alerts-page">
      <h1>Broadcast Alert</h1>
      <p className="subtitle">Send alerts to citizens via SMS and push notifications</p>

      <form onSubmit={handleSubmit} className="alert-form">
        <div className="form-group">
          <label htmlFor="message">Alert Message *</label>
          <textarea
            id="message"
            value={formData.message}
            onChange={(e) => setFormData({ ...formData, message: e.target.value })}
            placeholder="Enter alert message..."
            rows={4}
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="severity">Severity</label>
          <select
            id="severity"
            value={formData.severity}
            onChange={(e) => setFormData({ ...formData, severity: e.target.value })}
          >
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="critical">Critical</option>
          </select>
        </div>

        <div className="form-group">
          <label>Target Counties (Leave empty for all counties)</label>
          <div className="counties-grid">
            {LIBERIA_COUNTIES.map(county => (
              <label key={county} className="county-checkbox">
                <input
                  type="checkbox"
                  checked={formData.target_counties.includes(county)}
                  onChange={() => handleCountyToggle(county)}
                />
                <span>{county}</span>
              </label>
            ))}
          </div>
          {formData.target_counties.length > 0 && (
            <p className="selected-counties">
              Selected: {formData.target_counties.join(', ')}
            </p>
          )}
        </div>

        <div className="form-group">
          <label className="checkbox-label">
            <input
              type="checkbox"
              checked={formData.send_sms}
              onChange={(e) => setFormData({ ...formData, send_sms: e.target.checked })}
            />
            <span>Send via SMS</span>
          </label>
          <label className="checkbox-label">
            <input
              type="checkbox"
              checked={formData.send_push}
              onChange={(e) => setFormData({ ...formData, send_push: e.target.checked })}
            />
            <span>Send push notification</span>
          </label>
        </div>

        <button
          type="submit"
          className="btn-primary"
          disabled={broadcastMutation.isPending || !formData.message.trim()}
        >
          {broadcastMutation.isPending ? 'Broadcasting...' : 'Broadcast Alert'}
        </button>
      </form>
    </div>
  );
}
