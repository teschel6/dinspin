from pydantic import BaseModel


class MealCreate(BaseModel):
    description: str


class MealResponse(BaseModel):
    id: str
    description: str

    model_config = {"from_attributes": True}
