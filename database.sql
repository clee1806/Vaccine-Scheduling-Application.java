CREATE TABLE Vaccines (
    Name varchar(255),
    Doses INT,
    PRIMARY KEY (name)
);

CREATE TABLE Patients (
    Username varchar(255),
    Salt BINARY(16),
    Hash BINARY(16),
    PRIMARY KEY (Username)
);

CREATE TABLE Caregivers (
    Username varchar(255),
    Salt BINARY(16),
    Hash BINARY(16),
    PRIMARY KEY (Username)
);

CREATE TABLE Availabilities (
    Time date,
    cUser varchar(255) REFERENCES Caregivers(Username),
);

CREATE TABLE Appointments (
    Id INT IDENTITY(1,1),
    Time date,
    pUser varchar(255) REFERENCES Patients(Username),
    cUser varchar(255) REFERENCES Caregivers(Username),
    vaxName varchar(255) REFERENCES Vaccines(Name),
    PRIMARY KEY (Id)
);
