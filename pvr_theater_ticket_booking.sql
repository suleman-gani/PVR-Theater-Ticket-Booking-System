-- created database for PVR_theater
create database PVR_theater ;

use PVR_theater;

-- creating tables

CREATE TABLE Theater (
    TheaterID     INT            PRIMARY KEY,
    Name          VARCHAR(100)   NOT NULL,
    TicketType    VARCHAR(20)    NOT NULL,
    Rate          DECIMAL(8,2)   NOT NULL,
    MaxCapacity   INT            NOT NULL,
    BalCapacity   INT            NOT NULL
);

CREATE TABLE Bookings (
    BookingID    INT             AUTO_INCREMENT PRIMARY KEY,
    TheaterID    INT             NOT NULL,
    TrxDate      DATETIME        DEFAULT NOW(),
    TicketType   VARCHAR(20)     NOT NULL,
    Qty          INT             NOT NULL,
    Rate         DECIMAL(8,2)    NOT NULL,
    Amount       DECIMAL(10,2)   NOT NULL,
    FOREIGN KEY (TheaterID) REFERENCES Theater(TheaterID)
);

create table cancelledBookings (
	CancellationId	int				auto_increment primary key,
    BookingId		int				not null,
    TheaterId		int				not null,
    TrxDate			datetime		default now(),
    TicketType		varchar(50)		not null,
    Qty				int				not null,
    Rate			decimal(10,2)	not null,
    Amount			decimal(10,2)	not null,
    foreign key (BookingId) references Bookings(BookingId)
    );

-- inserting records into theater table

INSERT INTO Theater (TheaterID, Name, TicketType, Rate, MaxCapacity, BalCapacity)
VALUES
    (1, 'Grand Cinemas',   'Gold',     350.00, 100, 100),
    (2, 'Grand Cinemas',   'Silver',   200.00, 150, 150),
    (3, 'Starlight Plex',  'Platinum', 500.00,  60,  60),
    (4, 'Starlight Plex',  'Gold',     350.00,  80,  80),
    (5, 'Metro Movies',    'Silver',   180.00, 200, 200),
    (6, 'Metro Movies',    'Gold',     300.00, 120, 120)
    ;




-- stored procedure 'book_ticket' for booking tickets
delimiter //
create procedure book_ticket (
							in p_theaterid int,
                            in p_ticket_type varchar(50),
                            in p_qnty decimal(10,2),
                            out p_message varchar(100) 
                            )
begin 
		-- declaring local variables for temproray storing value
		declare v_rate decimal(10,2);
        declare v_balcapacity int;
        declare v_amount decimal(10,2);
         declare v_error_msg varchar(100);
         declare v_ticket_type varchar(100);

		-- declaring the handler to handle error condition
declare exit handler for sqlexception
	BEGIN
		rollback ;
        select 'Transaction failed' as result;
        resignal; 
        
	
	end;

start transaction ;
		-- select value from table and storing into local variables
		select rate, balcapacity, TicketType
				into v_rate, v_balcapacity, v_ticket_type
        from theater
        where theaterid = p_theaterid
        ;
       

		-- to raise error and show custom message and rollback
if
        p_ticket_type <> v_ticket_type then
        signal sqlstate '45000'
        set message_text = 'Please select a ticket type sold at your selected theater or try another theater';
        
elseif 
		p_qnty > v_balcapacity then
        set v_error_msg = concat('insufficient tickets available!. ','Currently,only ',v_balcapacity,' tickets are available.');
		signal sqlstate '45000'
		set message_text = v_error_msg;

elseif
		p_qnty <= 0 then
        signal sqlstate '45000'
        set message_text = 'please enter a valid quantity. Enter atleast 1 ';
        
else

		-- calculate v_amount (i.e total amount of ticket)
		set v_amount = p_qnty * v_rate ;
end if ;

		-- inserting the transaction records into bookings table
		insert into bookings 
					( theaterid, trxdate, tickettype, qty, rate, amount)
		values 		(p_theaterid, now(), p_ticket_type, p_qnty, v_rate, v_amount)
		;
        
If		
		last_insert_id() = 0 then
        signal sqlstate '45000'
        set message_text = 'Failed to insert records';

else
		
		-- updating the available quantity of tickets 
		update theater 
		set balcapacity = balcapacity - p_qnty
		where TheaterID = p_theaterid
		;

end if ;
  
if		 row_count() = 0 then
		signal sqlstate '45000'
		set message_text = 'Something wnent wrong whle updating';

else
        
        
		-- setting msg into out parameter (i.e p_message)
		set p_message = 'transaction successfull' ;

end if ;
        -- making changes to permanent changes
commit ;

end // 
delimiter ;








-- Stored Procedure 'Cancel_ticket' for ticket cancellation
delimiter //
create procedure cancel_ticket(
								in p_booking_id int,
                                in p_qnty int,
                                out p_message varchar(100)
                                )
                                
begin 
                             
-- declaring local variables for temproray storing value
		declare v_booking_id int;
        declare v_theater_id int;
		declare v_ticket_type varchar(50);
		declare v_qnty int;
		declare v_rate decimal(10,2);
		declare v_amount decimal(10,2);
        declare v_success_msg varchar(100);

-- Declaring exit handler for error handling
		Declare exit handler for sqlexception
		begin
				rollback;
				select 'Ticket cancellation failed' as result;
                resignal;
		end ;

	start transaction ;

-- select value from table and storing into local variables
		select
				BookingId, theaterId, ticketType, Qty, Rate
			into v_booking_id, v_theater_id, v_ticket_type, v_qnty, v_rate
		from bookings
		where BookingId = p_booking_id
		;

	

-- to raise error and show custom message and rollback
	if
		v_booking_id is null then
        signal sqlstate '45000'
        set message_text = 'Invalid booking id. Please enter valid booking id.'
        ;
        
	elseif
		p_qnty > v_qnty then
        signal sqlstate '45000'
        set message_text = 'Please enter ticket quantity equal to or less than you booked quantity'
        ;
        
	else
		-- calculate v_amount (i.e total amount of ticket)
        set v_amount = p_qnty * v_rate;
	
    end if;
    
    -- insert booking cancelled record into table 'CancelledBookings'
		
		insert into cancelledbookings
				(BookingId, TheaterId, TrxDate, TicketType, Qty, Rate, Amount)
		values
				(p_booking_id, v_theater_id, now(), v_ticket_type, p_qnty, v_rate, v_amount)
		;
	if
		last_insert_id() = 0 then
        signal sqlstate '45000'
        set message_text = 'Failed to insert records'
        ;
	
    else
    -- update available quantity 
    
		update theater
		set balcapacity = balcapacity + p_qnty
		where TheaterId = v_theater_id and
			  TicketType = v_ticket_type
	;
    
    end if ;
    
    if 
		row_count() = 0 then
        signal sqlstate '45000'
        set message_text = 'Something went wrong while updating Theater table'
        ;
	
    else
        
     -- update booking table record
		update bookings
		set Qty = v_qnty - p_qnty,
			Amount = (v_qnty - p_qnty) * v_rate
        where BookingId = p_booking_id
    
    ;
    
    end if;
    
    if
		row_count() = 0 then
        signal sqlstate '45000'
        set message_text = ' Something went wrong while updating Bookings table'
        ;
	
	else
    -- creating custom success msg into variable
    set v_success_msg = concat('success! ', p_qnty ,'tickets cancelled.') ;
    
    end if ;
    
    -- setting successfull transaction into out parameter
		set p_message = v_success_msg ;
        
	-- commit the transaction
    commit ;

end //

delimiter ;



-- calling the procedure (book_ticket)
call book_ticket(3,'Platinum',10,@msg_1);

-- select @message (i.e out parameter p_message)
select @msg_1;


-- calling the procedure (cancel_ticket)
call cancel_ticket(1,5,@msg_2);

-- select @msg(out paramter p_message)
select @msg_2;
