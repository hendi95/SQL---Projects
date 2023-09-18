

-- Question 1: List the publishers that have books available in multiple library branches.

SELECT p.publisher_name, b.book_title, lb.branch_name, SUM(bc.copies_no_Of_copies) AS total_copies
FROM publisher p
JOIN book b ON p.publisher_name = b.book_publisher_name
JOIN book_copies bc ON b.book_id = bc.copies_book_id
JOIN library_branch lb ON bc.copies_branch_id = lb.branch_id
WHERE b.book_id IN (
    SELECT DISTINCT b.book_id
    FROM book b
    JOIN book_copies bc ON b.book_id = bc.copies_book_id
    GROUP BY b.book_id
    HAVING COUNT(DISTINCT bc.copies_branch_id) > 1
)
GROUP BY p.publisher_name, b.book_title, lb.branch_name;



-- Question 2: Find the library branch with the highest total number of book copies available.
WITH BranchTotalCopies AS (
    SELECT lb.branch_name, SUM(bc.copies_no_Of_copies) AS total_copies
    FROM library_branch lb
    JOIN book_copies bc ON lb.branch_id = bc.copies_branch_id
    GROUP BY lb.branch_name
)
, MaxTotalCopies AS (
    SELECT MAX(total_copies) AS max_copies
    FROM BranchTotalCopies
)
SELECT btc.branch_name, btc.total_copies
FROM BranchTotalCopies btc
JOIN MaxTotalCopies mtc ON btc.total_copies = mtc.max_copies;

--Question 3: List the top 5 borrowers who have borrowed the most books from different authors.

SELECT TOP 5 br.borrower_name, COUNT(DISTINCT a.author_id) AS unique_authors
FROM borrower br
JOIN book_loans bl ON br.borrower_card_no = bl.loan_card_no
JOIN book b ON bl.loan_book_id = b.book_id
JOIN authors a ON b.book_id = a.author_book_id
GROUP BY br.borrower_name
ORDER BY unique_authors DESC;

--Question 4: Write a query to identify the book title with the most number of authors.

SELECT b.book_title, COUNT(a.author_id) AS author_count
FROM book b
JOIN authors a ON b.book_id = a.author_book_id
GROUP BY b.book_title
HAVING COUNT(a.author_id) = (
    SELECT MAX(author_count)
    FROM (
        SELECT COUNT(a2.author_id) AS author_count
        FROM book b2
        JOIN authors a2 ON b2.book_id = a2.author_book_id
        GROUP BY b2.book_title
    ) AS author_counts
);

--Question 5: Calculate the average number of copies available for each book.
SELECT b.book_title, AVG(bc.copies_no_Of_copies) AS avg_copies
FROM book b
JOIN book_copies bc ON b.book_id = bc.copies_book_id
GROUP BY b.book_title;

--Question 6: Identify the most common borrower address (city) among the borrowers.

WITH AddressCounts AS (
    SELECT borrower_address, COUNT(borrower_address) AS address_count
    FROM borrower
    GROUP BY borrower_address
)
, MaxAddressCount AS (
    SELECT MAX(address_count) AS max_count
    FROM AddressCounts
)
SELECT ac.borrower_address, ac.address_count
FROM AddressCounts ac
JOIN MaxAddressCount mac ON ac.address_count = mac.max_count;

--Question 7: Calculate the total number of overdue days for each  book in each library branch.
--Create another column that calculates the total overdue fines accumulated, 
--if the book has been returned before due date or equal to due date, than no penalty (0) if the book has been returned after due date, than 1 dollar penalty for each day.

SELECT lb.branch_name, b.book_title, 
       bl.loan_date_out, bl.loan_due_date, bl.loan_return_date,
       CASE 
           WHEN CONVERT(DATE, bl.loan_return_date, 1) > CONVERT(DATE, bl.loan_due_date, 1)
           THEN DATEDIFF(DAY, CONVERT(DATE, bl.loan_due_date, 1), CONVERT(DATE, bl.loan_return_date, 1))
           ELSE 0
       END AS overdue_days,
       CASE 
           WHEN CONVERT(DATE, bl.loan_return_date, 1) > CONVERT(DATE, bl.loan_due_date, 1)
           THEN DATEDIFF(DAY, CONVERT(DATE, bl.loan_due_date, 1), CONVERT(DATE, bl.loan_return_date, 1))
           ELSE 0
       END AS penalty_amount
FROM library_branch lb
JOIN book_loans bl ON lb.branch_id = bl.loan_branch_id
JOIN book b ON bl.loan_book_id = b.book_id;



--Question 8: Find the book title that has been borrowed the most times

SELECT b.book_title, COUNT(*) AS borrow_count
FROM book b
JOIN book_loans bl ON b.book_id = bl.loan_book_id
GROUP BY b.book_title
HAVING COUNT(*) = (
    SELECT TOP 1 COUNT(*)
    FROM book_loans
    GROUP BY loan_book_id
    ORDER BY COUNT(*) DESC
);



--Question 9: Calculate the average number of days each book is borrowed before being returned.

SELECT b.book_title, AVG(DATEDIFF(DAY, CONVERT(DATE, bl.loan_date_out, 1), CONVERT(DATE, bl.loan_return_date, 1))) AS avg_days_borrowed
FROM book b
JOIN book_loans bl ON b.book_id = bl.loan_book_id
GROUP BY b.book_title;


--Question 10: Create a Procedure to find number of copies of the book titled "The Lost Tribe" owned by the library branch whose name is "Sharpstown"? 

CREATE PROC p_book_copies_by_branch 
(@bookTitle varchar(70) = 'The Lost Tribe', @branchName varchar(70) = 'Sharpstown')
AS
SELECT bc.copies_branch_id AS [Branch ID], lb.branch_name AS [Branch Name],
	   bc.copies_no_Of_copies AS [Number of Copies],
	   b.book_Title AS [Book Title]
	   FROM book_copies AS bc
			INNER JOIN book AS b ON bc.copies_book_id = b.book_id
			INNER JOIN library_branch AS lb ON bc.copies_branch_id = lb.branch_id
	   WHERE b.book_title = @bookTitle AND lb.branch_name = @branchName
GO

EXEC dbo.p_book_copies_by_branch 


--Question 11- How many copies of the book titled "The Lost Tribe" are owned by each library branch? 

SELECT bc.copies_branch_id AS [Branch ID], lb.branch_name AS [Branch Name],
       bc.copies_no_Of_copies AS [Number of Copies],
       b.book_title AS [Book Title]
FROM book_copies bc
INNER JOIN book b ON bc.copies_book_id = b.book_id
INNER JOIN library_branch lb ON bc.copies_branch_id = lb.branch_id
WHERE b.book_title = 'The Lost Tribe';


--Question 12: For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

SELECT lb.branch_name AS [Branch Name], COUNT(bl.loan_branch_id) AS [Total Loans]
FROM book_loans bl
INNER JOIN library_branch lb ON bl.loan_branch_id = lb.branch_id
GROUP BY lb.branch_name;



