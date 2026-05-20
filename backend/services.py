from typing import TYPE_CHECKING, List
import database
import models
import schemas

if TYPE_CHECKING:
    from sqlalchemy.orm import Session

def _add_tables():
    return database.Base.metadata.create_all(bind = database.engine)

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def create_contact(contact: schemas.CreateContact, db: "Session") -> schemas.Contact:
    contact = models.Contact(**contact.model_dump())
    db.add(contact)
    db.commit()
    db.refresh(contact)
    return schemas.Contact.model_validate(contact)

async def get_all_contacts(db: "Session") -> List[schemas.Contact]:
    contacts = db.query(models.Contact).all()
    return list(map(schemas.Contact.model_validate, contacts))

async def get_contact(contact_id: int, db: "Session"):
    contact = db.query(models.Contact).filter(models.Contact.id == contact_id).first()
    return contact

async def delete_contact(contact: models.Contact, db: "Session"):
    db.delete(contact)
    db.commit()

async def update_contact(contact_data: schemas.CreateContact, contact: models.Contact, db: "Session") -> schemas.Contact:
    contact.first_name = contact_data.first_name
    contact.last_name = contact_data.last_name
    contact.email = contact_data.email
    contact.phone_number = contact_data.phone_number

    db.commit()
    db.refresh(contact)

    return schemas.Contact.model_validate(contact)
