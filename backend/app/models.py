from sqlalchemy import String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class Meal(Base):
    __tablename__ = "meals"

    id: Mapped[str] = mapped_column(String(26), primary_key=True)
    description: Mapped[str] = mapped_column(Text, nullable=False)
