from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ulid import ULID

from app.database import get_db
from app.models import Meal
from app.schemas import MealCreate, MealResponse

router = APIRouter(prefix="/meals", tags=["meals"])


@router.get("", response_model=list[MealResponse])
def get_meals(q: str | None = None, db: Session = Depends(get_db)):
    query = db.query(Meal)
    if q:
        query = query.filter(Meal.description.ilike(f"%{q}%"))
    return query.all()


@router.post("", response_model=MealResponse, status_code=201)
def create_meal(body: MealCreate, db: Session = Depends(get_db)):
    meal = Meal(id=str(ULID()), description=body.description)
    db.add(meal)
    db.commit()
    db.refresh(meal)
    return meal


@router.delete("/{id}", status_code=204)
def delete_meal(id: str, db: Session = Depends(get_db)):
    meal = db.query(Meal).filter(Meal.id == id).first()
    if not meal:
        raise HTTPException(status_code=404, detail="Meal not found")
    db.delete(meal)
    db.commit()
