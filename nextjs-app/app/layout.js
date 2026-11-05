export const metadata = { title: "FitPulse - Gym Membership Manager" };

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body style={{ fontFamily: "system-ui, sans-serif", margin: 0, background: "#f4f6fa", color: "#1b2733" }}>
        {children}
      </body>
    </html>
  );
}
