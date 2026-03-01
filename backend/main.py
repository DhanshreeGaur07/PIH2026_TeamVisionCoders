from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth, scrap, industry, products, coins, contracts

app = FastAPI(
    title="ScrapCrafters API",
    description="AI-Powered Circular Economy Platform Backend",
    version="1.0.0",
)

# CORS for Flutter web + mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(scrap.router)
app.include_router(industry.router)
app.include_router(products.router)
app.include_router(coins.router)
app.include_router(contracts.router)


@app.get("/")
async def root():
    return {
        "name": "ScrapCrafters API",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "docs": "/docs",
            "auth": "/auth",
            "scrap": "/scrap",
            "industry": "/industry",
            "products": "/products",
            "coins": "/coins",
            "contracts": "/contracts",
        },
    }


@app.get("/health")
async def health():
    return {"status": "healthy"}
