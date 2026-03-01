import artworkMetalKinetic from "../assets/artwork_metal_kinetic.png";
import artworkCircuitMandala from "../assets/artwork_circuit_mandala.png";
import artworkWoodFrame from "../assets/artwork_wood_frame.png";
import artworkCopperChimes from "../assets/artwork_copper_chimes.png";
import artworkPetLamp from "../assets/artwork_pet_lamp.png";
import artworkNewspaperSculpture from "../assets/artwork_newspaper_sculpture.png";

export const scrapItems = [
  { id: 1, title: "Copper Wire Bundle", category: "metal", weight: "2 kg", price: 80, image: "🔩", seller: "Ravi K.", status: "available", coins: 12 },
  { id: 2, title: "Old Circuit Boards", category: "e-waste", weight: "1.5 kg", price: 120, image: "💾", seller: "Priya M.", status: "available", coins: 18 },
  { id: 3, title: "Teak Wood Offcuts", category: "wood", weight: "10 kg", price: 200, image: "🪵", seller: "Arjun S.", status: "available", coins: 30 },
  { id: 4, title: "PET Bottles (50 pcs)", category: "plastic", weight: "3 kg", price: 45, image: "🫙", seller: "Meena R.", status: "available", coins: 8 },
  { id: 5, title: "Iron Rods Assorted", category: "metal", weight: "5 kg", price: 150, image: "🔧", seller: "Suresh T.", status: "available", coins: 22 },
  { id: 6, title: "Old Newspapers Bulk", category: "paper", weight: "8 kg", price: 30, image: "📰", seller: "Lata B.", status: "available", coins: 5 },
  { id: 7, title: "Broken Clock Parts", category: "metal", weight: "0.8 kg", price: 60, image: "⚙️", seller: "Dev P.", status: "available", coins: 9 },
  { id: 8, title: "Fabric Scraps (Cotton)", category: "textile", weight: "4 kg", price: 55, image: "🧵", seller: "Sana K.", status: "available", coins: 7 },
  { id: 9, title: "Glass Bottles (20)", category: "glass", weight: "6 kg", price: 40, image: "🍶", seller: "Nisha M.", status: "available", coins: 6 },
];

export const artworksSold = [
  { id: 1, title: "Scrap Metal Kinetic", buyer: "ArtHouse Delhi", price: 3500, date: "Feb 22, 2025", medium: "Metal + Wire" },
  { id: 2, title: "Circuit Board Mandala", buyer: "TechMuseum Bengaluru", price: 2800, date: "Feb 18, 2025", medium: "E-Waste" },
  { id: 3, title: "Upcycled Wood Frame", buyer: "GreenHome Decor", price: 1200, date: "Feb 10, 2025", medium: "Reclaimed Wood" },
  { id: 4, title: "Copper Wind Chimes", buyer: "EcoLiving Co.", price: 950, date: "Jan 30, 2025", medium: "Copper Wire" },
];

export const transformations = [
  { id: 1, from: "Copper Wire Bundle", to: "Kinetic Sculpture", status: "In Progress", progress: 65 },
  { id: 2, from: "Old Circuit Boards", to: "Digital Wall Art", status: "Completed", progress: 100 },
  { id: 3, from: "PET Bottles", to: "Garden Lamp", status: "Listed", progress: 100 },
  { id: 4, from: "Teak Wood Offcuts", to: "Decorative Shelf", status: "In Progress", progress: 30 },
];

export const userListings = [
  { id: 1, title: "Old Bicycle Frame", category: "metal", price: 300, status: "Pending", date: "Feb 25", image: "🚲", views: 14 },
  { id: 2, title: "Broken Laptop", category: "e-waste", price: 500, status: "Sold", date: "Feb 20", image: "💻", views: 38 },
  { id: 3, title: "Glass Jars (10)", category: "glass", price: 0, status: "Donated", date: "Feb 15", image: "🫙", views: 7 },
  { id: 4, title: "Steel Pipe Bundle", category: "metal", price: 180, status: "Pending", date: "Feb 26", image: "🔩", views: 5 },
];

export const helperTasks = [
  {
    id: 1,
    assignedTo: "GreenArt Studio, FC Road, Pune",
    pickup: "12, MG Road, Shivajinagar, Pune",
    dropoff: "GreenArt Studio, FC Road, Pune",
    items: "Metal scraps, copper wire bundles",
    weight: "15 kg",
    status: "pending",
    reward: 45,
    urgent: true,
    scheduledAt: "Today, 10:00 AM",
    distance: "3.4 km",
  },
  {
    id: 2,
    assignedTo: "EcoHub Warehouse, Aundh",
    pickup: "7, Baner Road, Baner, Pune",
    dropoff: "EcoHub Warehouse, Aundh, Pune",
    items: "PET bottles, cardboard boxes",
    weight: "8 kg",
    status: "collected",
    reward: 28,
    urgent: false,
    scheduledAt: "Today, 1:30 PM",
    distance: "2.1 km",
  },
  {
    id: 3,
    assignedTo: "Creative Collective, Peth",
    pickup: "23, Karve Nagar, Kothrud, Pune",
    dropoff: "Creative Collective, Kasba Peth, Pune",
    items: "E-waste components, circuit boards",
    weight: "5 kg",
    status: "delivered",
    reward: 35,
    urgent: false,
    scheduledAt: "Today, 9:00 AM",
    distance: "5.7 km",
  },
];

/* Artworks with waste utilised (kg) for gallery & detail */
export const artworks = [
  { id: 101, title: "Scrap Metal Kinetic Sculpture", category: "artwork", price: 3500, image: "🔩", imageUrl: artworkMetalKinetic, seller: "Ravi K.", status: "active", waste_used_kg: 12.5, medium: "Metal + Wire" },
  { id: 102, title: "Circuit Board Mandala", category: "artwork", price: 2800, image: "💾", imageUrl: artworkCircuitMandala, seller: "Priya M.", status: "active", waste_used_kg: 3.2, medium: "E-Waste" },
  { id: 103, title: "Upcycled Wood Frame", category: "artwork", price: 1200, image: "🪵", imageUrl: artworkWoodFrame, seller: "Arjun S.", status: "active", waste_used_kg: 8, medium: "Reclaimed Wood" },
  { id: 104, title: "Copper Wind Chimes", category: "artwork", price: 950, image: "🔩", imageUrl: artworkCopperChimes, seller: "Meena R.", status: "active", waste_used_kg: 2.1, medium: "Copper Wire" },
  { id: 105, title: "PET Bottle Garden Lamp", category: "artwork", price: 650, image: "🫙", imageUrl: artworkPetLamp, seller: "Sana K.", status: "active", waste_used_kg: 1.8, medium: "Plastic" },
  { id: 106, title: "Newspaper Pulp Sculpture", category: "artwork", price: 480, image: "📰", imageUrl: artworkNewspaperSculpture, seller: "Lata B.", status: "active", waste_used_kg: 5.5, medium: "Paper" },
];

export const platformStats = {
  itemsRecycled: "12,400+",
  artists: "500+",
  incomeGenerated: "₹48 L",
  wasteDiverted: "8.2 T",
};

export const categoryColors = {
  metal: { bg: "bg-slate-100", text: "text-slate-700", border: "border-slate-200" },
  plastic: { bg: "bg-blue-50", text: "text-blue-700", border: "border-blue-200" },
  "e-waste": { bg: "bg-yellow-50", text: "text-yellow-700", border: "border-yellow-200" },
  wood: { bg: "bg-amber-50", text: "text-amber-700", border: "border-amber-200" },
  paper: { bg: "bg-lime-50", text: "text-lime-700", border: "border-lime-200" },
  glass: { bg: "bg-cyan-50", text: "text-cyan-700", border: "border-cyan-200" },
  textile: { bg: "bg-pink-50", text: "text-pink-700", border: "border-pink-200" },
  other: { bg: "bg-stone-100", text: "text-stone-700", border: "border-stone-200" },
};
