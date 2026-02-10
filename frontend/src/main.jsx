import React, { useState } from 'react'
import { createRoot } from 'react-dom/client'

function App() {
  const [celsius, setCelsius] = useState('')
  const [kelvin, setKelvin] = useState(null)

  async function convert() {
    const res = await fetch('/api/celsius-to-kelvin', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ celsius: Number(celsius) })
    })

    const data = await res.json()
    setKelvin(data.kelvin)
  }

  return (
    <div style={{ padding: 40 }}>
      <h1>Celsius → Kelvin</h1>

      <input
        type="number"
        value={celsius}
        onChange={e => setCelsius(e.target.value)}
      />

      <button onClick={convert}>Umrechnen</button>

      {kelvin !== null && <p>{kelvin} K</p>}
    </div>
  )
}

createRoot(document.getElementById('root')).render(<App />)
