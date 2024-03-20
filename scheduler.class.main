package scheduler;

import scheduler.db.ConnectionManager;
import scheduler.model.Caregiver;
import scheduler.model.Patient;
import scheduler.model.Vaccine;
import scheduler.util.Util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Date;

public class Scheduler {

    // objects to keep track of the currently logged-in user
    // Note: it is always true that at most one of currentCaregiver and currentPatient is not null
    //       since only one user can be logged-in at a time
    private static Caregiver currentCaregiver = null;
    private static Patient currentPatient = null;

    public static void main(String[] args) {
        // printing greetings text
        System.out.println();
        System.out.println("Welcome to the COVID-19 Vaccine Reservation Scheduling Application!");
        printMenu();

        // read input from user
        BufferedReader r = new BufferedReader(new InputStreamReader(System.in));
        while (true) {
            System.out.print("> ");
            String response = "";
            try {
                response = r.readLine();
            } catch (IOException e) {
                System.out.println("Please try again!");
            }
            // split the user input by spaces
            String[] tokens = response.split(" ");
            // check if input exists
            if (tokens.length == 0) {
                continue;
            }
            // determine which operation to perform
            String operation = tokens[0];
            if (operation.equals("create_patient")) {
                createPatient(tokens);
            } else if (operation.equals("create_caregiver")) {
                createCaregiver(tokens);
            } else if (operation.equals("login_patient")) {
                loginPatient(tokens);
            } else if (operation.equals("login_caregiver")) {
                loginCaregiver(tokens);
            } else if (operation.equals("search_caregiver_schedule")) {
                searchCaregiverSchedule(tokens);
            } else if (operation.equals("reserve")) {
                reserve(tokens);
            } else if (operation.equals("upload_availability")) {
                uploadAvailability(tokens);
            } else if (operation.equals("cancel")) {
                cancel(tokens);
            } else if (operation.equals("add_doses")) {
                addDoses(tokens);
            } else if (operation.equals("show_appointments")) {
                showAppointments(tokens);
            } else if (operation.equals("logout")) {
                logout(tokens);
            } else if (operation.equals("quit")) {
                System.out.println("Bye!");
                return;
            } else {
                System.out.println("Invalid operation name!");
            }
        }
    }

    private static void printMenu() {
        System.out.println("*** Please enter one of the following commands ***");
        System.out.println("> create_patient <username> <password>");  //TODO: implement create_patient (Part 1)
        System.out.println("> create_caregiver <username> <password>");
        System.out.println("> login_patient <username> <password>");  // TODO: implement login_patient (Part 1)
        System.out.println("> login_caregiver <username> <password>");
        System.out.println("> search_caregiver_schedule <date>");  // TODO: implement search_caregiver_schedule (Part 2)
        System.out.println("> reserve <date> <vaccine>");  // TODO: implement reserve (Part 2)
        System.out.println("> upload_availability <date>");
        System.out.println("> cancel <appointment_id>");  // TODO: implement cancel (extra credit)
        System.out.println("> add_doses <vaccine> <number>");
        System.out.println("> show_appointments");  // TODO: implement show_appointments (Part 2)
        System.out.println("> logout");  // TODO: implement logout (Part 2)
        System.out.println("> quit");
        System.out.println();
    }

    private static void createPatient(String[] tokens) {
        if (tokens.length != 3) {
            System.out.println("Failed to create user.");
            return;
        }
        String username = tokens[1];
        String password = tokens[2];
        if (usernameExistsPatient(username)) {
            System.out.println("Username taken, try again!");
            return;
        }
        byte[] salt = Util.generateSalt();
        byte[] hash = Util.generateHash(password, salt);
        // create the caregiver
        try {
            Patient patient = new Patient.PatientBuilder(username, salt, hash).build();
            patient.saveToDB();
            System.out.println("Created user " + username);
            printMenu();
        } catch (SQLException e) {
            System.out.println("Failed to create user.");
            e.printStackTrace();
        }
    }

    private static boolean usernameExistsPatient(String username) {
        ConnectionManager cm = new ConnectionManager();
        Connection con = cm.createConnection();

        String selectUsername = "SELECT * FROM Patients WHERE Username = ?";
        try {
            PreparedStatement statement = con.prepareStatement(selectUsername);
            statement.setString(1, username);
            ResultSet resultSet = statement.executeQuery();
            return resultSet.isBeforeFirst();
        } catch (SQLException e) {
            System.out.println("Error occurred when checking username");
            e.printStackTrace();
        } finally {
            cm.closeConnection();
        }
        return true;
    }

    private static void createCaregiver(String[] tokens) {
        // create_caregiver <username> <password>
        // check 1: the length for tokens need to be exactly 3 to include all information (with the operation name)
        if (tokens.length != 3) {
            System.out.println("Failed to create user.");
            return;
        }
        String username = tokens[1];
        String password = tokens[2];
        // check 2: check if the username has been taken already
        if (usernameExistsCaregiver(username)) {
            System.out.println("Username taken, try again!");
            return;
        }
        byte[] salt = Util.generateSalt();
        byte[] hash = Util.generateHash(password, salt);
        // create the caregiver
        try {
            Caregiver caregiver = new Caregiver.CaregiverBuilder(username, salt, hash).build(); 
            // save to caregiver information to our database
            caregiver.saveToDB();
            System.out.println("Created user " + username);
            printMenu();
        } catch (SQLException e) {
            System.out.println("Failed to create user.");
            e.printStackTrace();
        }
    }

    private static boolean usernameExistsCaregiver(String username) {
        ConnectionManager cm = new ConnectionManager();
        Connection con = cm.createConnection();

        String selectUsername = "SELECT * FROM Caregivers WHERE Username = ?";
        try {
            PreparedStatement statement = con.prepareStatement(selectUsername);
            statement.setString(1, username);
            ResultSet resultSet = statement.executeQuery();
            // returns false if the cursor is not before the first record or if there are no rows in the ResultSet.
            return resultSet.isBeforeFirst();
        } catch (SQLException e) {
            System.out.println("Error occurred when checking username");
            e.printStackTrace();
        } finally {
            cm.closeConnection();
        }
        return true;
    }

    private static void loginPatient(String[] tokens) {
        if (currentPatient != null || currentPatient != null) {
            System.out.println("User already logged in.");
            return;
        }
        if (tokens.length != 3) {
            System.out.println("Login failed.");
            return;
        }
        String username = tokens[1];
        String password = tokens[2];

        Patient patient = null;
        try {
            patient = new Patient.PatientGetter(username, password).get();
        } catch (SQLException e) {
            System.out.println("Login failed.");
            e.printStackTrace();
        }
        // check if the login was successful
        if (patient == null) {
            System.out.println("Login failed.");
        } else {
            System.out.println("Logged in as: " + username);
            currentPatient = patient;
        }
    }

    private static void loginCaregiver(String[] tokens) {
        // login_caregiver <username> <password>
        // check 1: if someone's already logged-in, they need to log out first
        if (currentCaregiver != null || currentPatient != null) {
            System.out.println("User already logged in.");
            return;
        }
        // check 2: the length for tokens need to be exactly 3 to include all information (with the operation name)
        if (tokens.length != 3) {
            System.out.println("Login failed.");
            return;
        }
        String username = tokens[1];
        String password = tokens[2];

        Caregiver caregiver = null;
        try {
            caregiver = new Caregiver.CaregiverGetter(username, password).get();
        } catch (SQLException e) {
            System.out.println("Login failed.");
            e.printStackTrace();
        }
        // check if the login was successful
        if (caregiver == null) {
            System.out.println("Login failed.");
        } else {
            System.out.println("Logged in as: " + username);
            currentCaregiver = caregiver;
        }
    }

    private static void searchCaregiverSchedule(String[] tokens) {
        if (currentCaregiver == null && currentPatient == null) {
            System.out.println("Please login first!");
            return;
        }
        if (tokens.length != 2) {
            System.out.println("Please try again!");
            return;
        }
        String date = tokens[1];
        ConnectionManager cm = new ConnectionManager();
        Connection con = cm.createConnection();
        String getAvailability = "SELECT cUser FROM Availabilities WHERE Time = ? ORDER BY cUser";
        try {
            Date d = Date.valueOf(date);
            PreparedStatement statement = con.prepareStatement(getAvailability);
            statement.setDate(1, d);
            ResultSet resultSet = statement.executeQuery();
            System.out.print("Caregivers available: ");
            while (resultSet.next()) {
                String user = resultSet.getString("cUser");
                System.out.print(user + " ");
            }
            System.out.println();
            String getVaccines = "SELECT * FROM Vaccines";
            PreparedStatement statement1 = con.prepareStatement(getVaccines);
            ResultSet resultSet1 = statement1.executeQuery();
            System.out.print("Vaccines available: ");
            while (resultSet1.next()) {
                String vaxName = resultSet1.getString("Name");
                int doses = resultSet1.getInt("Doses");
                System.out.print(vaxName + " " + doses + " ");
            }
            System.out.println();
            printMenu();
        } catch (IllegalArgumentException e) {
            System.out.println("Please enter a valid date!");
        } catch (SQLException e) {
            System.out.println("Error occurred when searching caregiver schedule.");
            e.printStackTrace();
        } finally {
            cm.closeConnection();
        }
    }

    private static void reserve(String[] tokens) {
        if (currentPatient == null && currentCaregiver == null) {
            System.out.println("Please login first!");
            return;
        }
        if (currentCaregiver != null) {
            System.out.println("Please login as a patient first!");
            return;
        }
        if (tokens.length != 3) {
            System.out.println("Please try again!");
            return;
        }
        String date = tokens[1];
        String vaxName = tokens[2];
        Vaccine vaccine = null;
        ConnectionManager cm = new ConnectionManager();
        Connection con = cm.createConnection();
        String getCaregiver = "SELECT TOP 1 cUser FROM Availabilities WHERE Time = ? ORDER BY cUser";
        try {
            Date d = Date.valueOf(date);
            PreparedStatement statement = con.prepareStatement(getCaregiver);
            statement.setDate(1, d);
            ResultSet resultSet = statement.executeQuery();
            String cUser = null;
            if (!resultSet.next()) {
                System.out.println("No Caregiver is available!");
            } else {
                String checkVax = "SELECT Doses FROM Vaccines WHERE Name = ?";
                try {
                    PreparedStatement statement1 = con.prepareStatement(checkVax);
                    statement1.setString(1, vaxName);
                    ResultSet resultSet1 = statement1.executeQuery();
                    if (!resultSet1.next()) {
                        System.out.println("Vaccine is not available!");
                        return;
                    } else {
                        int doses = resultSet1.getInt("Doses");
                        if (doses == 0) {
                            System.out.println("Not enough available doses!");
                            return;
                        }
                    }
                } catch(SQLException e){
                    System.out.println("Please try again!");
                    e.printStackTrace();
                }
                cUser = resultSet.getString("cUser");
                String uploadAppointment = "INSERT INTO Appointments (Time, pUser, cUser, vaxName) VALUES (? , ?, ?, ?)";
                try {
                    PreparedStatement statement2 = con.prepareStatement(uploadAppointment);
                    statement2.setDate(1, d);
                    statement2.setString(2, currentPatient.getUsername());
                    statement2.setString(3, cUser);
                    statement2.setString(4, vaxName);
                    statement2.executeUpdate();
                } catch (SQLException e) {
                    System.out.println("Please try again!");
                    e.printStackTrace();
                }
                try {
                    vaccine = new Vaccine.VaccineGetter(vaxName).get();
                    vaccine.decreaseAvailableDoses(1);
                } catch (SQLException e) {
                    System.out.println("Please try again!");
                    e.printStackTrace();
                }
                String getAppointment = "SELECT Id, cUser FROM Appointments WHERE Time = ? AND pUser = ?" +
                        " AND cUser = ? AND vaxName = ?";
                PreparedStatement statement4 = con.prepareStatement(getAppointment);
                statement4.setDate(1, d);
                statement4.setString(2, currentPatient.getUsername());
                statement4.setString(3, cUser);
                statement4.setString(4, vaxName);
                ResultSet resultSet3 = statement4.executeQuery();
                while (resultSet3.next()) {
                    int id = resultSet3.getInt("Id");
                    String user = resultSet3.getString("cUser");
                    System.out.println("Appointment ID: " + id + ", Caregiver username: " + user);
                }
                String remove = "DELETE FROM Availabilities WHERE Time = ? AND cUser = ?";
                try {
                    PreparedStatement statement3 = con.prepareStatement(remove);
                    statement3.setDate(1, d);
                    statement3.setString(2, cUser);
                    statement3.executeUpdate();
                } catch (SQLException e) {
                    System.out.println("Please try again!");
                    e.printStackTrace();
                }
                cUser = cUser;
                printMenu();
            }
        } catch (IllegalArgumentException e) {
            System.out.println("Please enter a valid value!");
        } catch (SQLException e) {
            System.out.println("Error occurred when reserving appointment.");
            e.printStackTrace();
        } finally {
            cm.closeConnection();
        }
    }

    private static void uploadAvailability(String[] tokens) {
        // upload_availability <date>
        // check 1: check if the current logged-in user is a caregiver
        if (currentCaregiver == null) {
            System.out.println("Please login as a caregiver first!");
            return;
        }
        // check 2: the length for tokens need to be exactly 2 to include all information (with the operation name)
        if (tokens.length != 2) {
            System.out.println("Please try again!");
            return;
        }
        String date = tokens[1];
        try {
            Date d = Date.valueOf(date);
            currentCaregiver.uploadAvailability(d);
            System.out.println("Availability uploaded!");
            printMenu();
        } catch (IllegalArgumentException e) {
            System.out.println("Please enter a valid date!");
        } catch (SQLException e) {
            System.out.println("Error occurred when uploading availability");
            e.printStackTrace();
        }
    }

    private static void cancel(String[] tokens) {
        if (currentPatient == null && currentCaregiver == null) {
            System.out.println("Please login first!");
            return;
        }
        if (tokens.length != 2) {
            System.out.println("Please try again!");
            return;
        }
        String id = tokens[1];
        Vaccine vaccine = null;
        ConnectionManager cm = new ConnectionManager();
        Connection con = cm.createConnection();
        String getVaccine = "SELECT vaxName FROM Appointments WHERE Id = ?";
        String cancelAppointment = "DELETE FROM Appointments WHERE Id = ?";
        try {
            PreparedStatement statement = con.prepareStatement(getVaccine);
            statement.setInt(1, Integer.parseInt(id));
            ResultSet resultSet = statement.executeQuery();
            while (resultSet.next()) {
                String vaxName = resultSet.getString("vaxName");
                vaccine = new Vaccine.VaccineGetter(vaxName).get();
                vaccine.increaseAvailableDoses(1);
            }
            PreparedStatement statement1 = con.prepareStatement(cancelAppointment);
            statement1.setInt(1, Integer.parseInt(id));
            statement1.executeUpdate();
            System.out.println("Appointment successfully canceled!");
            printMenu();
        } catch (SQLException e) {
            System.out.println("Error occurred attempting to cancel appointment.");
            e.printStackTrace();
        } finally {
            cm.closeConnection();
        }
    }

    private static void addDoses(String[] tokens) {
        // add_doses <vaccine> <number>
        // check 1: check if the current logged-in user is a caregiver
        if (currentCaregiver == null) {
            System.out.println("Please login as a caregiver first!");
            return;
        }
        // check 2: the length for tokens need to be exactly 3 to include all information (with the operation name)
        if (tokens.length != 3) {
            System.out.println("Please try again!");
            return;
        }
        String vaccineName = tokens[1];
        int doses = Integer.parseInt(tokens[2]);
        Vaccine vaccine = null;
        try {
            vaccine = new Vaccine.VaccineGetter(vaccineName).get();
        } catch (SQLException e) {
            System.out.println("Error occurred when adding doses");
            e.printStackTrace();
        }
        // check 3: if getter returns null, it means that we need to create the vaccine and insert it into the Vaccines
        //          table
        if (vaccine == null) {
            try {
                vaccine = new Vaccine.VaccineBuilder(vaccineName, doses).build();
                vaccine.saveToDB();
            } catch (SQLException e) {
                System.out.println("Error occurred when adding doses");
                e.printStackTrace();
            }
        } else {
            // if the vaccine is not null, meaning that the vaccine already exists in our table
            try {
                vaccine.increaseAvailableDoses(doses);
            } catch (SQLException e) {
                System.out.println("Error occurred when adding doses");
                e.printStackTrace();
            }
        }
        System.out.println("Doses updated!");
        printMenu();
    }

    private static void showAppointments(String[] tokens) {
        if (currentCaregiver == null && currentPatient == null) {
            System.out.println("Please login first!");
            return;
        }
        ConnectionManager cm = new ConnectionManager();
        Connection con = cm.createConnection();
        if (currentCaregiver != null) {
            String getAppointments = "SELECT Id, vaxName, Time, pUser FROM Appointments WHERE cUser = ? ORDER BY Id";
            try {
                PreparedStatement statement = con.prepareStatement(getAppointments);
                statement.setString(1, currentCaregiver.getUsername());
                ResultSet resultSet = statement.executeQuery();
                System.out.println("Scheduled appointments: ");
                while (resultSet.next()) {
                    int id = resultSet.getInt("Id");
                    String vaxName = resultSet.getString("vaxName");
                    Date d = resultSet.getDate("Time");
                    String pUser = resultSet.getString("pUser");
                    System.out.println(id + " " + vaxName + " " + d + " " + pUser);
                }
            } catch (SQLException e) {
                System.out.println("Error occurred when finding scheduled appointments.");
                e.printStackTrace();
            }
        }
        if (currentPatient != null) {
            String getAppointments = "SELECT Id, vaxName, Time, cUser FROM Appointments WHERE pUser = ? ORDER BY Id";
            try {
                PreparedStatement statement1 = con.prepareStatement(getAppointments);
                statement1.setString(1, currentPatient.getUsername());
                ResultSet resultSet1 = statement1.executeQuery();
                System.out.println("Scheduled appointments: ");
                while (resultSet1.next()) {
                    int id = resultSet1.getInt("Id");
                    String vaxName = resultSet1.getString("vaxName");
                    Date d = resultSet1.getDate("Time");
                    String cUser = resultSet1.getString("cUser");
                    System.out.println(id + " " + vaxName + " " + d + " " + cUser);
                }
            } catch (SQLException e) {
                System.out.println("Error occurred when finding scheduled appointments.");
                e.printStackTrace();
            } finally {
                cm.closeConnection();
            }
        }
        printMenu();
    }

    private static void logout(String[] tokens) {
        if (currentCaregiver == null && currentPatient == null) {
            System.out.println("Please login first.");
        } else if (currentPatient != null) {
            currentPatient = null;
            System.out.println("Successfully logged out!");
        } else if (currentCaregiver != null) {
            currentCaregiver = null;
            System.out.println("Successfully logged out!");
        } else {
            System.out.println("Please try again.");
        }
        printMenu();
    }
}
