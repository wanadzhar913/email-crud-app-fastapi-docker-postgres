import datetime as dt
from pydantic import BaseModel

class _BaseContact(BaseModel):
    first_name: str
    last_name: str
    email: str
    phone_number: str

class Contact(_BaseContact):
    id: int
    date_created: dt.datetime

    class Config:
        from_attributes = True

class CreateContact(_BaseContact):
    pass
