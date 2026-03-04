import React, { useState, useEffect } from 'react';
import { 
  User, 
  MessageSquare, 
  TrendingUp, 
  Award, 
  Bell, 
  BookOpen, 
  LogOut, 
  Send,
  ChevronRight,
  Target
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';

type UserProfile = {
  id: number;
  name: string;
  email: string;
  role: string;
  district: string;
  points: number;
  level: number;
};

type AIResponse = {
  intent: string;
  confidence: number;
  response: string;
  suggestions: string[];
};

export default function App() {
  const [user, setUser] = useState<UserProfile | null>(null);
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));
  const [view, setView] = useState<'auth' | 'dashboard'>('auth');
  const [authMode, setAuthMode] = useState<'login' | 'register'>('login');
  
  // Auth Form
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [district, setDistrict] = useState('');

  // AI Panel
  const [query, setQuery] = useState('');
  const [aiResult, setAiResult] = useState<AIResponse | null>(null);
  const [loading, setLoading] = useState(false);

  // Recommendations
  const [schemes, setSchemes] = useState<any[]>([]);
  
  // Market
  const [crop, setCrop] = useState('Wheat');
  const [prediction, setPrediction] = useState<any>(null);

  // Leaderboard
  const [leaderboard, setLeaderboard] = useState<any[]>([]);

  useEffect(() => {
    if (token) {
      fetchProfile();
      setView('dashboard');
    }
  }, [token]);

  const fetchProfile = async () => {
    try {
      const res = await fetch('/api/auth/profile', {
        headers: { Authorization: `Bearer ${token}` }
      });
      if (res.ok) {
        const data = await res.json();
        setUser(data);
        fetchRecommendations(data.id);
        fetchLeaderboard();
      } else {
        logout();
      }
    } catch (err) {
      logout();
    }
  };

  const fetchRecommendations = async (userId: number) => {
    const res = await fetch(`/api/ai/recommendations?userId=${userId}`);
    const data = await res.json();
    setSchemes(data);
  };

  const fetchLeaderboard = async () => {
    const res = await fetch('/api/gamification/leaderboard');
    const data = await res.json();
    setLeaderboard(data);
  };

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    const endpoint = authMode === 'login' ? '/api/auth/login' : '/api/auth/register';
    const body = authMode === 'login' ? { email, password } : { name, email, password, district };
    
    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
      
      const data = await res.json();
      if (res.ok) {
        localStorage.setItem('token', data.token);
        setToken(data.token);
        setUser(data.user);
        setView('dashboard');
      } else {
        alert(data.error || 'Authentication failed');
      }
    } catch (err) {
      console.error('Auth error:', err);
      alert('Connection error. Please try again.');
    }
  };

  const logout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setUser(null);
    setView('auth');
  };

  const handleQuery = async () => {
    if (!query) return;
    setLoading(true);
    try {
      const res = await fetch('/api/ai/query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query, userId: user?.id })
      });
      const data = await res.json();
      setAiResult(data);
      
      // Track action for points
      await fetch('/api/gamification/action', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: user?.id, action: 'ai_query' })
      });
      fetchProfile();
    } finally {
      setLoading(false);
    }
  };

  const handlePredict = async () => {
    const res = await fetch('/api/market/predict', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ crop })
    });
    const data = await res.json();
    setPrediction(data);
  };

  if (view === 'auth') {
    return (
      <div className="min-h-screen bg-[#F5F2ED] flex items-center justify-center p-4">
        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white p-8 rounded-3xl shadow-xl w-full max-w-md border border-[#5A5A40]/10"
        >
          <div className="text-center mb-8">
            <h1 className="text-4xl font-serif text-[#5A5A40] mb-2">SathiAI</h1>
            <p className="text-sm text-[#5A5A40]/60 uppercase tracking-widest">Your Rural Companion</p>
          </div>

          <form onSubmit={handleAuth} className="space-y-4">
            {authMode === 'register' && (
              <>
                <input 
                  type="text" placeholder="Full Name" value={name} onChange={e => setName(e.target.value)}
                  className="w-full p-4 rounded-2xl bg-[#F5F2ED] border-none focus:ring-2 focus:ring-[#5A5A40]"
                />
                <input 
                  type="text" placeholder="District" value={district} onChange={e => setDistrict(e.target.value)}
                  className="w-full p-4 rounded-2xl bg-[#F5F2ED] border-none focus:ring-2 focus:ring-[#5A5A40]"
                />
              </>
            )}
            <input 
              type="email" placeholder="Email Address" value={email} onChange={e => setEmail(e.target.value)}
              className="w-full p-4 rounded-2xl bg-[#F5F2ED] border-none focus:ring-2 focus:ring-[#5A5A40]"
            />
            <input 
              type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)}
              className="w-full p-4 rounded-2xl bg-[#F5F2ED] border-none focus:ring-2 focus:ring-[#5A5A40]"
            />
            <button type="submit" className="w-full py-4 bg-[#5A5A40] text-white rounded-full font-medium hover:bg-[#4A4A30] transition-colors">
              {authMode === 'login' ? 'Sign In' : 'Create Account'}
            </button>
          </form>

          <div className="mt-6 text-center">
            <button 
              onClick={() => setAuthMode(authMode === 'login' ? 'register' : 'login')}
              className="text-sm text-[#5A5A40] hover:underline"
            >
              {authMode === 'login' ? "Don't have an account? Register" : "Already have an account? Login"}
            </button>
          </div>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F5F2ED] text-[#1A1A1A] font-sans">
      {/* Header */}
      <header className="bg-white border-b border-[#5A5A40]/10 px-6 py-4 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-2">
            <div className="w-10 h-10 bg-[#5A5A40] rounded-full flex items-center justify-center text-white">
              S
            </div>
            <h1 className="text-2xl font-serif text-[#5A5A40]">SathiAI</h1>
          </div>
          <div className="flex items-center gap-6">
            <div className="hidden md:flex items-center gap-4">
              <div className="flex flex-col items-end">
                <span className="text-xs font-bold text-[#5A5A40]/40 uppercase tracking-tighter">Level {user?.level}</span>
                <span className="text-sm font-medium">{user?.points} Points</span>
              </div>
              <div className="w-12 h-12 bg-[#F5F2ED] rounded-full flex items-center justify-center">
                <Award className="w-6 h-6 text-[#5A5A40]" />
              </div>
            </div>
            <button onClick={logout} className="p-2 hover:bg-[#F5F2ED] rounded-full transition-colors">
              <LogOut className="w-5 h-5 text-[#5A5A40]/60" />
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto p-6 grid grid-cols-1 lg:grid-cols-12 gap-6">
        {/* Left Column: AI Assistant */}
        <div className="lg:col-span-8 space-y-6">
          <section className="bg-white rounded-3xl p-6 shadow-sm border border-[#5A5A40]/5">
            <div className="flex items-center gap-3 mb-6">
              <MessageSquare className="w-6 h-6 text-[#5A5A40]" />
              <h2 className="text-xl font-serif text-[#5A5A40]">Rural Assistant</h2>
            </div>
            
            <div className="space-y-4 mb-6 min-h-[200px] bg-[#F5F2ED]/30 rounded-2xl p-4">
              {aiResult ? (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  <p className="text-lg leading-relaxed text-[#5A5A40] mb-4">{aiResult.response}</p>
                  <div className="flex flex-wrap gap-2">
                    {Array.isArray(aiResult.suggestions) && aiResult.suggestions.map((s, i) => (
                      <button 
                        key={i} 
                        onClick={() => { setQuery(s); handleQuery(); }}
                        className="px-4 py-2 bg-white border border-[#5A5A40]/10 rounded-full text-sm hover:bg-[#5A5A40] hover:text-white transition-all"
                      >
                        {s}
                      </button>
                    ))}
                  </div>
                </motion.div>
              ) : (
                <div className="flex flex-col items-center justify-center h-full text-[#5A5A40]/40 py-12">
                  <Target className="w-12 h-12 mb-4 opacity-20" />
                  <p>Ask me about farming, schemes, or market prices</p>
                </div>
              )}
            </div>

            <div className="flex gap-2">
              <input 
                type="text" 
                value={query}
                onChange={e => setQuery(e.target.value)}
                onKeyPress={e => e.key === 'Enter' && handleQuery()}
                placeholder="Type your question here..."
                className="flex-1 p-4 rounded-2xl bg-[#F5F2ED] border-none focus:ring-2 focus:ring-[#5A5A40]"
              />
              <button 
                onClick={handleQuery}
                disabled={loading}
                className="p-4 bg-[#5A5A40] text-white rounded-2xl hover:bg-[#4A4A30] disabled:opacity-50 transition-all"
              >
                {loading ? <div className="w-6 h-6 border-2 border-white/30 border-t-white rounded-full animate-spin" /> : <Send className="w-6 h-6" />}
              </button>
            </div>
          </section>

          {/* Market Prediction */}
          <section className="bg-white rounded-3xl p-6 shadow-sm border border-[#5A5A40]/5">
            <div className="flex items-center justify-between mb-6">
              <div className="flex items-center gap-3">
                <TrendingUp className="w-6 h-6 text-[#5A5A40]" />
                <h2 className="text-xl font-serif text-[#5A5A40]">Market Intelligence</h2>
              </div>
              <select 
                value={crop} 
                onChange={e => setCrop(e.target.value)}
                className="bg-[#F5F2ED] border-none rounded-xl px-4 py-2 text-sm focus:ring-2 focus:ring-[#5A5A40]"
              >
                <option>Wheat</option>
                <option>Rice</option>
                <option>Cotton</option>
                <option>Maize</option>
              </select>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-[#F5F2ED] rounded-2xl p-6">
                <h3 className="text-sm font-bold text-[#5A5A40]/40 uppercase tracking-widest mb-4">7-Day Forecast</h3>
                {prediction && Array.isArray(prediction.forecast) ? (
                  <div className="space-y-3">
                    {prediction.forecast.map((f: any) => (
                      <div key={f.day} className="flex justify-between items-center">
                        <span className="text-sm text-[#5A5A40]/60">Day {f.day}</span>
                        <span className="font-mono font-medium">₹{f.price}</span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <button onClick={handlePredict} className="w-full py-3 border-2 border-dashed border-[#5A5A40]/20 rounded-xl text-[#5A5A40]/40 hover:border-[#5A5A40]/40 transition-all">
                    Generate Forecast
                  </button>
                )}
              </div>
              <div className="flex flex-col justify-center">
                <h3 className="text-sm font-bold text-[#5A5A40]/40 uppercase tracking-widest mb-2">Recommendation</h3>
                <p className="text-lg text-[#5A5A40]">
                  {prediction ? prediction.recommendation : "Select a crop and generate forecast to see market advice."}
                </p>
              </div>
            </div>
          </section>
        </div>

        {/* Right Column: Schemes & Leaderboard */}
        <div className="lg:col-span-4 space-y-6">
          {/* Recommended Schemes */}
          <section className="bg-white rounded-3xl p-6 shadow-sm border border-[#5A5A40]/5">
            <div className="flex items-center gap-3 mb-6">
              <Bell className="w-6 h-6 text-[#5A5A40]" />
              <h2 className="text-xl font-serif text-[#5A5A40]">For You</h2>
            </div>
            <div className="space-y-4">
              {Array.isArray(schemes) && schemes.map((s: any) => (
                <div key={s.id} className="group p-4 rounded-2xl bg-[#F5F2ED] hover:bg-[#5A5A40] hover:text-white transition-all cursor-pointer">
                  <h3 className="font-medium mb-1">{s.title}</h3>
                  <p className="text-xs opacity-60 line-clamp-2 mb-3">{s.description}</p>
                  <div className="flex justify-between items-center">
                    <span className="text-[10px] uppercase tracking-widest font-bold">Ends: {s.deadline}</span>
                    <ChevronRight className="w-4 h-4 opacity-0 group-hover:opacity-100 transition-all" />
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Leaderboard */}
          <section className="bg-[#5A5A40] rounded-3xl p-6 shadow-sm text-white">
            <div className="flex items-center gap-3 mb-6">
              <Award className="w-6 h-6" />
              <h2 className="text-xl font-serif">Top Sathi's</h2>
            </div>
            <div className="space-y-4">
              {Array.isArray(leaderboard) && leaderboard.map((l: any, i: number) => (
                <div key={i} className="flex items-center justify-between py-2 border-b border-white/10 last:border-0">
                  <div className="flex items-center gap-3">
                    <span className="text-xs font-bold opacity-40">{i + 1}</span>
                    <span className="text-sm font-medium">{l.name}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs opacity-60">Lvl {l.level}</span>
                    <span className="text-sm font-mono">{l.points}</span>
                  </div>
                </div>
              ))}
            </div>
          </section>

          {/* Quick Skills */}
          <section className="bg-white rounded-3xl p-6 shadow-sm border border-[#5A5A40]/5">
            <div className="flex items-center gap-3 mb-4">
              <BookOpen className="w-6 h-6 text-[#5A5A40]" />
              <h2 className="text-xl font-serif text-[#5A5A40]">Skill Up</h2>
            </div>
            <p className="text-sm text-[#5A5A40]/60 mb-4">Complete quick modules to earn points and level up.</p>
            <button className="w-full py-3 bg-[#F5F2ED] text-[#5A5A40] rounded-xl font-medium hover:bg-[#5A5A40] hover:text-white transition-all">
              Browse Skills
            </button>
          </section>
        </div>
      </main>
    </div>
  );
}
