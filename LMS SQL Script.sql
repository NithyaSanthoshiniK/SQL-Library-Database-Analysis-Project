create database lms;
use lms;
drop table tbl_publisher;

CREATE TABLE tbl_publisher (
    publisher_PublisherName VARCHAR(255) PRIMARY KEY,
    publisher_PublisherAddress VARCHAR(255),
    publisher_PublisherPhone VARCHAR(20) 
);

create table tbl_borrower
(
borrower_CardNo int auto_increment primary key,
borrwer_BorrowerName varchar(255),
borrwer_BorrowerAddress varchar(255),
borrwer_BorrowerPhone VARCHAR(20)
) ;

create table tbl_library_branch(
    library_branch_branchID INT AUTO_INCREMENT PRIMARY KEY,
    library_branch_BranchName VARCHAR(255),
    library_branch_BranchAddress VARCHAR(255)
    );

CREATE TABLE tbl_book
(
    book_BookID INT AUTO_INCREMENT PRIMARY KEY,
    book_Title VARCHAR(255),
    book_PublisherName VARCHAR(255) NOT NULL,
	FOREIGN KEY (book_PublisherName) REFERENCES tbl_publisher(publisher_PublisherName)
	ON DELETE CASCADE ON UPDATE CASCADE
);

create table tbl_book_authors
(
book_authors_AuthorID int auto_increment primary key,
book_authors_BookID int,
book_authors_AuthorName varchar(255) not null,
foreign key (book_authors_BookID) references tbl_book(book_BookID)
ON DELETE CASCADE ON UPDATE CASCADE
) ;

CREATE TABLE tbl_book_copies (
    book_copies_CopiesID INT AUTO_INCREMENT PRIMARY KEY,
    book_copies_BookID INT,
    book_copies_BranchID INT,
    book_copies_No_Of_Copies INT,
    FOREIGN KEY (book_copies_BookID) REFERENCES tbl_book(book_BookID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_copies_BranchID) REFERENCES tbl_library_branch(library_branch_branchID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE tbl_book_loans (
    book_loans_LoansID INT AUTO_INCREMENT PRIMARY KEY,
    book_loans_BookID INT,
    book_loans_BranchID INT,
    book_loans_CardNo INT,
    book_loans_DateOut DATE,
    book_loans_DueDate DATE,
    FOREIGN KEY (book_loans_BookID) REFERENCES tbl_book(book_BookID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_loans_BranchID) REFERENCES tbl_library_branch(library_branch_branchID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (book_loans_CardNo) REFERENCES tbl_borrower(borrower_CardNo) ON DELETE CASCADE ON UPDATE CASCADE
);

select * from tbl_publisher;
select * from tbl_borrower;
select * from tbl_library_branch;
select * from tbl_book;
select * from tbl_book_authors;
select * from tbl_book_copies;
select * from tbl_book_loans;

-- 1. How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?
select tbl_library_branch.library_branch_branchID,
	   tbl_book_copies.book_copies_BranchID,
       tbl_book_copies.book_copies_No_of_Copies
from 
       tbl_library_branch
left join
       tbl_book_copies on library_branch_branchID = book_copies_BranchID
where 
	   tbl_library_branch.library_branch_BranchName = 'Sharpstown'
       and tbl_book_copies.book_copies_BookID IN (
           select book_BookID from tbl_book where book_title = 'The Lost Tribe'
           );
           
-- 2. How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select tbl_library_branch.library_branch_BranchName,
       tbl_book.book_Title as 'Book Title',
       sum(tbl_book_copies.book_copies_No_of_Copies) as 'count of books'
from 
       tbl_library_branch
JOIN
    tbl_book_copies ON tbl_library_branch.library_branch_branchID = tbl_book_copies.book_copies_BranchID
JOIN
    tbl_book ON tbl_book_copies.book_copies_BookID = tbl_book.book_BookID
where 
	    tbl_book.book_title = 'The Lost Tribe'
group by 
        tbl_book.book_Title, tbl_library_branch.library_branch_BranchName;
        
-- 3. Retrieve the names of all borrowers who do not have any books checked out.
select tbl_borrower.borrwer_BorrowerName as 'Borrower Name'
from tbl_borrower
left join tbl_book_loans on tbl_borrower.borrower_CardNo = tbl_book_loans.book_loans_CardNo
           where tbl_book_loans.book_loans_CardNo is null;
      
-- 4. For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, the borrower's name, and the borrower's address.       
select tbl_book.book_Title as 'Book Title',
tbl_borrower.borrwer_BorrowerName as 'Borrower Name',
tbl_borrower.borrwer_BorrowerAddress as 'Borrower Address'
from tbl_book_loans
join tbl_book on tbl_book_loans.book_loans_BookID = tbl_book.book_BookID
join tbl_borrower on tbl_book_loans.book_loans_CardNo = tbl_borrower.borrower_CardNo
join tbl_library_branch on tbl_book_loans.book_loans_BranchID = tbl_library_branch.library_branch_BranchID
where tbl_library_branch.library_branch_BranchName = 'Sharpstown'
and tbl_book_loans.book_loans_Duedate = '2018-02-03';
           
           
-- 5. For each library branch, retrieve the branch name and the total number of books loaned out from that branch.
select tbl_library_branch.library_branch_BranchName as 'Branch Name', 
count(tbl_book_loans.book_loans_LoansID) as 'Total Books Loaned'
from tbl_library_branch
left join tbl_book_loans on tbl_library_branch.library_branch_BranchID = tbl_book_loans.book_loans_BranchID
group by tbl_library_branch.library_branch_BranchName;
           
-- 6. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out.
select tbl_borrower.borrwer_BorrowerName as 'Borrower Name',
tbl_borrower.borrwer_BorrowerAddress as 'Borrower Address',
count(tbl_book_loans.book_loans_LoansID) as 'No. of Books checked out'
from tbl_borrower
join tbl_book_loans on tbl_borrower.borrower_CardNo = tbl_book_loans.book_loans_CardNo
group by tbl_borrower.borrower_CardNo
having count(tbl_book_loans.book_loans_LoansID) > 5;
           
-- 7. For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".
select tbl_book.book_Title as 'Book Title',
count(tbl_book_copies.book_copies_No_Of_Copies) as 'number of Copies'
from tbl_book
join tbl_book_copies on tbl_book.book_BookID = tbl_book_copies.book_copies_BookID
join tbl_library_branch on tbl_book_copies.book_copies_BranchID = tbl_library_branch.library_branch_BranchID
where tbl_book.book_Title in (
select book_Title from tbl_book 
join tbl_book_authors on tbl_book.book_BookID = tbl_book_authors.book_authors_BookID
where tbl_book_authors.book_authors_AuthorName = 'Stephen King'
)
and tbl_library_branch.library_branch_BranchName = 'Central'
group by 
tbl_book.book_BookID,tbl_book.book_Title;
           

           
           
           
           