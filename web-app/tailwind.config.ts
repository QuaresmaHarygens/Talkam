import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#1F4DD8",
          foreground: "#ffffff",
        },
        secondary: {
          DEFAULT: "#1ABF7E",
          foreground: "#ffffff",
        },
        background: "var(--background)",
        foreground: "var(--foreground)",
      },
      borderRadius: {
        DEFAULT: "12px",
        lg: "16px",
        md: "12px",
        sm: "8px",
      },
      spacing: {
        "8": "8px",
        "16": "16px",
        "24": "24px",
      },
    },
  },
  plugins: [],
};

export default config;
