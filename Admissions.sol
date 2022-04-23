pragma solidity ^0.5.1;

contract Admissions {
    enum ApplicationStatus {
        APPLIED,
        SHORTLISTED,
        ACCEPTED
    }

    struct Application {
        uint _id;
        address student;
        address college;
        ApplicationStatus status;
    }

    mapping(uint => Application) public applications;
    uint applicationCount = 0;

    //      student => application ids
    mapping(address => uint[]) studentApplications;
    //      college => application ids
    mapping(address => uint[]) collegeApplications;

    modifier onlyCollege() {
        require(colleges[msg.sender]._id != 0, "College not registered");
        _;
    }

    modifier onlyStudent() {
        require(students[msg.sender]._id != 0, "Student not registered");
        _;
    }

    modifier newUser() {
        require(students[msg.sender]._id == 0, "User registered as student.");
        require(colleges[msg.sender]._id == 0, "User registered as a college.");
        _;
    }

    modifier validApplication(uint applicationId) {
        require(applications[applicationId]._id != 0, "Invalid Application");
        _;
    }


    // region College -----------------------------------
    struct College {
        uint _id;
        string name;
    }

    mapping(address => College) public colleges;
    uint collegeCount = 0;

    function registerCollege(string memory name) public newUser{
        collegeCount += 1;
        colleges[msg.sender] = College(collegeCount, name);
    }
    // endregion ------------------------------

    // region Student ----------------------------------
    struct Student {
        uint _id;
        string name;
        uint marks;
    }

    mapping(address => Student) public students;
    uint studentCount = 0;
    function registerStudent(string memory name, uint marks) public newUser{
        studentCount += 1;
        students[msg.sender] = Student(studentCount, name, marks);
    }
    // endregion ------------------------------

    function applyToCollege(address college_addr) public onlyStudent{
        require(colleges[college_addr]._id != 0, "Invalid College. College not registered.");

        applicationCount += 1;
        Application memory application = Application(applicationCount, msg.sender, college_addr, ApplicationStatus.APPLIED);

        applications[applicationCount] = application;

        studentApplications[msg.sender].push(applicationCount);
        collegeApplications[college_addr].push(applicationCount);
    }

    function getApplications() public view returns(uint[] memory) {
        require(colleges[msg.sender]._id != 0 || students[msg.sender]._id != 0, "User is not registered");
        if (colleges[msg.sender]._id != 0) {
            return collegeApplications[msg.sender];
        } else {
            return studentApplications[msg.sender];
        }
    }

    function shortlistApplication(uint applicationId) public onlyCollege validApplication(applicationId){
        uint[] memory _applications = getApplications();
        bool found = false;
        for(uint i = 0; i < _applications.length; i++) {
            if (_applications[i] == applicationId) {
                found = true;
                break;
            }
        }

        require(found, "Invalid Application");

        Application storage application = applications[applicationId];

        require(application.status == ApplicationStatus.APPLIED, "Cannot shortlist application.");
        application.status = ApplicationStatus.SHORTLISTED;
    }

    function acceptApplication(uint applicationId) public onlyStudent validApplication(applicationId){
        uint[] memory _applications = getApplications();
        bool found = false;
        for(uint i = 0; i < _applications.length; i++) {
            if (_applications[i] == applicationId) {
                found = true;
                break;
            }
        }

        require(found, "Invalid Application");
        Application storage application = applications[applicationId];

        require(application.status == ApplicationStatus.SHORTLISTED, "Cannot accept application.");
        application.status = ApplicationStatus.ACCEPTED;
    }
}
