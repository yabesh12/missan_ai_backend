from fastapi import APIRouter

router = APIRouter()

@router.get("/")
async def get_billing_info():
    return {"message": "Billing info route working"}
