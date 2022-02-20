//SPDX-License-Identifier: MIT
// solidity last version, safemath added and other functions to prevent overflows and underflows.

/// @title MOVIES APP IN THE CHAIN.
/// @author dimitrix1337
/// @notice You can use this contract for everything.
/// @dev All function calls are currently implemented without side effects
/// @custom:im newbie at solidity, you can found errors.

pragma solidity ^0.8.12;

contract movies_chain {


// ------ STATE VARIABLES ------------    

    // declare some variables and some events.
    uint256 id = 0;
    address owner;

// ------ EVENTS ------------    

    event movieadded(string title, uint256 time);
    event MovieAlreadyExists(string title);
    event PointsAdded(string title, uint32 points);
    event MovieNotExists(string title);

// ------ CONSTRUCTOR ------------    

    // initialize admin address.
    constructor () {
        // if msg.sender is 0x0 it can't be possible. (prevent bugs)
        if (msg.sender!=address(0)) {
            owner = msg.sender; }
    }

// ------ MAPPINGS ------------    
    mapping(address => User) users;

    mapping(uint256 => Movie) movies;

// ------ STRUCTS ------------    
    struct Movie {
        string title;
        string description;
        string genre;
        string image_link;
        string url;
        string quality;
        uint32 points;
        uint128 duration;
    }

    struct User {

        string username;
        uint64 movies_saw;
        uint256 time_passed;
        // mapping to set every user watched movie points.
        // the strings is the title of the movie, and the uint32 is the quantity of points, max 5 and min 0. 

        mapping(string => uint32) points;
    }

    // ------ MODIFIERS ------------    


    // movie exist?
    modifier MovieExists(string memory title, bool exist) {
        
        if (exist) {
            require(!alreadyExists(title), "Error: movie exists");
            _;
        }
        else {
            require(alreadyExists(title), "Error: movie don't exist");
            _;
        }

    }
 
    // only the user who was launched the contract is the owner.
    modifier OnlyAdmin() {

        require(msg.sender == owner, "You not are the admin.");
        _;
    }

    // if the user already gave points to this movie
    modifier not_added_points(string memory title_movie) {

        require(users[msg.sender].points[title_movie]==0, "Error: you already gave points to this movie.");
        _;
    }

    // min 0 points and max 5 points to all movies.
    modifier max_points(uint32 points) {

        require(verifyPoints(points), "Max points is 5 and min is 0.");
        _;
    }

    // movie id exists? the id is used for mapping of movies.
    // each added movie the id is += 1 . the id is a state variable, so, it always more than before then added movie.
    modifier id_exists(uint256 _id) {
        require(keccak256(abi.encodePacked(movies[_id].title))==keccak256(abi.encodePacked("")), "Error: movie ID don't exist.");
        _;
    }

    // ------ FUNCTIONS  ------------    

    // function to complete the modifier of max points. 
    // i like make this syntax , i mean, create function to modifier, is very comfortable to me.
    function verifyPoints(uint32 _points) private pure returns(bool) {

        if (_points<=5 && _points>=0) {
            return true;
        } else {
            return false;
        }

    }  


    // function to transfer the owner, an assert to safe transaction.
    function transfer_owner(address _to) public OnlyAdmin() {

        assert(msg.sender == owner);        
        owner = _to;

    }

    // function to add an movie, only owner can do this.
    function addMovie(string memory title, string memory description, string memory genre, string memory image_link, string memory url, string memory quality, uint128 duration) public OnlyAdmin MovieExists(title, true) returns(bool) {
        
        movies[id].title = title;
        movies[id].description = description;
        movies[id].genre = genre;
        movies[id].points = 0;
        movies[id].image_link = image_link;
        movies[id].url = url;
        movies[id].quality = quality;
        movies[id].duration = duration;
        // very important to add +1 to the state variable id.
        id++;
        emit movieadded(title, block.timestamp);

        return true;
    }

    // a for loop to determine if the movie exists, iterating each movies[i] where the i is the loop for variable.
    function alreadyExists(string memory name) private returns (bool) {
        
        for (uint32 i=0;i<=id;i++) {

            // solidity don't has string comparations, so, i use the hash algorithm keccak256 to determinate this comparison.
            if (keccak256(abi.encodePacked(movies[i].title))==keccak256(abi.encodePacked(name))) {

                emit MovieAlreadyExists(name);
                return true;    
            }
        }
        return false;
    }

    // function to return a little info about the movie , the user give the id.
    function getMovie(uint256 _id) public view returns(string memory title, string memory genre, uint32 points) {
        return (movies[_id].title, movies[_id].genre, movies[_id].points);
    }

    // function to addpoints to a movie.
    function addPoints(string memory title, uint32 points) public MovieExists(title, false) not_added_points(title) max_points(points) returns(bool)  {

        for (uint k=0;k<=id;k++) {

            // solidity don't has string comparations, so, i use the hash algorithm keccak256 to determinate this comparison.
            if (keccak256(abi.encodePacked(title))==keccak256(abi.encodePacked(movies[k].title))) {

                movies[k].points += points;
                // add to the user address , the title of movie to search in the mapping and add him points to verify the user already gave points.
                users[msg.sender].points[title] = points;
                emit PointsAdded(title, points);
                return true;
            }   

        }

        emit MovieNotExists(title);
        return false;

    }



}

// end of the contract.