------------------------------------------------
------------CREATING DATABASE-------------------
USE MASTER;
GO
IF DB_ID('SPOTIFY') IS NOT NULL
    DROP DATABASE SPOTIFY
CREATE DATABASE SPOTIFY
GO
USE SPOTIFY;
GO
------------CREATING DATABASE-------------------
------------------------------------------------




------------------------------------------------
----------------OTHER---------------------------
CREATE TABLE Languages (
	LanguageID INT PRIMARY KEY,
 	Name NVARCHAR(50) NOT NULL,
  	
  	CONSTRAINT UQ_Languages_Name UNIQUE(Name)
);
GO


CREATE TABLE Countries (
	CountryID INT PRIMARY KEY,
  	Name NVARCHAR(50) NOT NULL,
  	
  	CONSTRAINT UQ_Countries_Name UNIQUE(Name)
);
GO
----------------OTHER---------------------------
------------------------------------------------





--------------------------------------------------
-------------------USERS--------------------------
CREATE TABLE Users (
    UserID INT PRIMARY KEY,
    Username NVARCHAR(50) NOT NULL,
    Email NVARCHAR(50) NOT NULL,
	DateOfBirth DATE NOT NULL,
	RegistrationDate DATETIME DEFAULT GETDATE() NOT NULL,
	CountryID INT NOT NULL,

	CONSTRAINT UQ_Users_Username UNIQUE(Username),
	CONSTRAINT UQ_Users_Email UNIQUE(Email),

	CONSTRAINT CK_Users_DateOfBirth
		CHECK (DateOfBirth <= GETDATE()),
	CONSTRAINT CK_Users_Email_Format
        CHECK (Email LIKE '%_@_%._%'),

	CONSTRAINT FK_Users_Countries
		FOREIGN KEY (CountryID)
        REFERENCES Countries(CountryID)
);
GO


CREATE TABLE SubscriptionTypes (
    SubscriptionTypeID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Price MONEY NOT NULL,
    DurationMonths INT NOT NULL,
  	
  	CONSTRAINT UQ_SubscriptionTypes_Name UNIQUE (Name),

  	CONSTRAINT CK_SubscriptionTypes_Price
  		CHECK (Price >= 0),
  	CONSTRAINT CK_SubscriptionTypes_DurationMonths
  		CHECK (DurationMonths > 0)
);
GO


CREATE TABLE UserSubscriptions (
    UserSubscriptionID INT PRIMARY KEY,
    UserID INT NOT NULL,                         
    SubscriptionTypeID INT NOT NULL,             
    StartDate DATE DEFAULT CAST(GETDATE() AS DATE) NOT NULL,                    
    EndDate DATE,
    IsActive BIT,

	CONSTRAINT FK_UserSubscriptions_Users
		FOREIGN KEY (UserID)
		REFERENCES Users(UserID),
	CONSTRAINT FK_UserSubscriptions_SubscriptionTypes
		FOREIGN KEY (SubscriptionTypeID)
		REFERENCES SubscriptionTypes(SubscriptionTypeID)
);
GO


CREATE TABLE DeviceTypes (
    DeviceTypeID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
  
 	CONSTRAINT UQ_DeviceTypes_Name UNIQUE (Name)
);
GO
-------------------USERS--------------------------
--------------------------------------------------





--------------------------------------------------
--------------------MUSIC-------------------------
CREATE TABLE Labels (
    LabelID INT PRIMARY KEY,
    Name NVARCHAR(200) NOT NULL,
    CountryID INT NOT NULL,
    ContactEmail NVARCHAR(255) NULL,

    CONSTRAINT UQ_Labels_Name UNIQUE (Name),

    CONSTRAINT CK_Labels_ContactEmail_Format
        CHECK (
			ContactEmail IS NULL OR
			(ContactEmail LIKE '%_@_%._%')
			),

	CONSTRAINT FK_Labels_Countries
		FOREIGN KEY (CountryID)
        REFERENCES Countries(CountryID)
);
GO


CREATE TABLE Genres (
    GenreID INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    PopularityFromYear INT NOT NULL,
    PopularityToYear INT NOT NULL,

	CONSTRAINT UQ_Genres_Name UNIQUE (Name),

    CONSTRAINT CK_Genres_PopularityRange
        CHECK (PopularityFromYear <= PopularityToYear)
);
GO


CREATE TABLE Producers (
    ProducerID INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    CountryID INT NOT NULL,

	CONSTRAINT FK_Producers_Countries
		FOREIGN KEY (CountryID)
        REFERENCES Countries(CountryID)
);
GO


CREATE TABLE Artists (
    ArtistID INT PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    CountryID INT NOT NULL,
    LabelID INT NULL,

    CONSTRAINT FK_Artists_Labels
        FOREIGN KEY (LabelID) 
		REFERENCES Labels(LabelID),
	CONSTRAINT FK_Artists_Countries
		FOREIGN KEY (CountryID)
        REFERENCES Countries(CountryID)
);
GO


CREATE TABLE Albums (
    AlbumID INT PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    ReleaseDate DATETIME DEFAULT GETDATE(),
    AlbumType NVARCHAR(20) NOT NULL,

    CONSTRAINT CK_Albums_AlbumType
        CHECK (AlbumType IN ('ALBUM', 'SINGLE')),
    CONSTRAINT CK_Albums_ReleaseDate
        CHECK (ReleaseDate <= GETDATE())
);
GO


CREATE TABLE Songs (
    SongID INT PRIMARY KEY,
    Title NVARCHAR(200) NOT NULL,
    DurationSeconds INT NOT NULL,
    IsExplicit BIT NOT NULL DEFAULT 0,
    ReleaseDate DATETIME DEFAULT GETDATE(),
    AlbumID INT NULL,
    GenreID INT NULL,
    ProducerID INT NOT NULL,
    StreamCount INT NOT NULL DEFAULT 0,

    CONSTRAINT CK_Songs_DurationSeconds
        CHECK (DurationSeconds > 0),
    CONSTRAINT CK_Songs_ReleaseDate
        CHECK (ReleaseDate <= GETDATE()),

	CONSTRAINT FK_Songs_Albums
        FOREIGN KEY (AlbumID)
        REFERENCES Albums(AlbumID),
    CONSTRAINT FK_Songs_Genres
        FOREIGN KEY (GenreID)
        REFERENCES Genres(GenreID),
	CONSTRAINT FK_Songs_Producers
        FOREIGN KEY (ProducerID)
        REFERENCES Producers(ProducerID)
);
GO


CREATE TABLE SongCreators (
    SongID INT NOT NULL,
    ArtistID INT NOT NULL,

	PRIMARY KEY (SongID, ArtistID),

    CONSTRAINT FK_SongCreators_Songs
        FOREIGN KEY (SongID)
        REFERENCES Songs(SongID),
    CONSTRAINT FK_SongCreators_Artists
        FOREIGN KEY (ArtistID)
        REFERENCES Artists(ArtistID)
);
GO


CREATE TABLE AlbumCreators (
    AlbumID INT NOT NULL,
    ArtistID INT NOT NULL,

	PRIMARY KEY (AlbumID, ArtistID),

    CONSTRAINT FK_AlbumCreators_Albums
        FOREIGN KEY (AlbumID)
        REFERENCES Albums(AlbumID),
    CONSTRAINT FK_AlbumCreators_Artists
        FOREIGN KEY (ArtistID)
        REFERENCES Artists(ArtistID)
);
GO
--------------------MUSIC-------------------------
--------------------------------------------------





--------------------------------------------------
--------------------PODCASTS----------------------
CREATE TABLE PodcastCategories (
    CategoryID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,

	CONSTRAINT UQ_PodcastCategories_Name UNIQUE (Name)
);
GO


CREATE TABLE Podcasts (
    PodcastID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    CategoryID INT,
    LanguageID INT,
    EpisodeCount INT NOT NULL DEFAULT 0,

	CONSTRAINT UQ_Podcasts_Name UNIQUE (Name),

	CONSTRAINT FK_Podcasts_PodcastCategories
        FOREIGN KEY (CategoryID)
        REFERENCES PodcastCategories(CategoryID),
	CONSTRAINT FK_Podcasts_Languages
        FOREIGN KEY (LanguageID)
        REFERENCES Languages(LanguageID)
);
GO


CREATE TABLE PodcastEpisodes (
    EpisodeID INT PRIMARY KEY,
    PodcastID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    DurationSeconds INT,
    ReleaseDate DATETIME DEFAULT GETDATE(),
    StreamCount INT NOT NULL DEFAULT 0,

	CONSTRAINT CK_PodcastEpisodes_DurationSeconds
        CHECK (DurationSeconds > 0),
	CONSTRAINT CK_PodcastEpisodes_ReleaseDate
        CHECK (ReleaseDate <= GETDATE()),

    CONSTRAINT FK_PodcastEpisodes_Podcasts
        FOREIGN KEY (PodcastID)
        REFERENCES Podcasts(PodcastID)
);
GO
--------------------PODCASTS----------------------
--------------------------------------------------





--------------------------------------------------
--------------------ADS---------------------------
CREATE TABLE Advertisers (
    AdvertiserID INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    CountryID INT NOT NULL,
  	
  	CONSTRAINT UQ_Advertisers_Name UNIQUE (Name),

 	CONSTRAINT FK_Advertisers_Countries
  		FOREIGN KEY (CountryID)
  		REFERENCES Countries(CountryID)
);
GO


CREATE TABLE Ads (
    AdID INT PRIMARY KEY,
    AdvertiserID INT NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    DurationSeconds INT NOT NULL,
    StreamCount INT NOT NULL DEFAULT 0,
  
 	CONSTRAINT CK_Ads_DurationSeconds
  		CHECK (DurationSeconds > 0),

	CONSTRAINT FK_Ads_Advertisers
  		FOREIGN KEY (AdvertiserID)
  		REFERENCES Advertisers(AdvertiserID)
);
GO
--------------------ADS---------------------------
--------------------------------------------------





--------------------------------------------------
--------------------FOLLOWS-LIKES-----------------
CREATE TABLE FollowsArtists (
	UserID INT NOT NULL,
	ArtistID INT NOT NULL,
    FollowDate DATETIME DEFAULT GETDATE(),

	PRIMARY KEY (UserID, ArtistID),

	CONSTRAINT CK_FollowsArtists_FollowDate
        CHECK (FollowDate <= GETDATE()),

	CONSTRAINT FK_FollowsArtists_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID),
	CONSTRAINT FK_FollowsArtists_Artists
        FOREIGN KEY (ArtistID)
        REFERENCES Artists(ArtistID)
);
GO


CREATE TABLE FollowsPodcasts (
	UserID INT NOT NULL,
	PodcastID INT NOT NULL,
    FollowDate DATETIME DEFAULT GETDATE(),

	PRIMARY KEY (UserID, PodcastID),

	CONSTRAINT CK_FollowsPodcasts_FollowDate
        CHECK (FollowDate <= GETDATE()),

	CONSTRAINT FK_FollowsPodcasts_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID),
	CONSTRAINT FK_FollowsPodcasts_Podcasts
        FOREIGN KEY (PodcastID)
        REFERENCES Podcasts(PodcastID)
);
GO


CREATE TABLE SongLikes (
	UserID INT NOT NULL,
	SongID INT NOT NULL,
    LikeDate DATETIME DEFAULT GETDATE(),

	PRIMARY KEY (UserID, SongID),

	CONSTRAINT CK_SongLikes_LikeDate
        CHECK (LikeDate <= GETDATE()),

	CONSTRAINT FK_SongLikes_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID),
	CONSTRAINT FK_SongLikes_Songs
        FOREIGN KEY (SongID)
        REFERENCES Songs(SongID)
);
GO


CREATE TABLE EpisodeLikes (
	UserID INT NOT NULL,
	EpisodeID INT NOT NULL,
    LikeDate DATETIME DEFAULT GETDATE(),

	PRIMARY KEY (UserID, EpisodeID),

	CONSTRAINT CK_EpisodeLikes_LikeDate
        CHECK (LikeDate <= GETDATE()),

	CONSTRAINT FK_EpisodeLikes_Users
        FOREIGN KEY (UserID)
        REFERENCES Users(UserID),
	CONSTRAINT FK_EpisodeLikes_PodcastEpisodes
        FOREIGN KEY (EpisodeID)
        REFERENCES PodcastEpisodes(EpisodeID)
);
GO
--------------------FOLLOWS-LIKES-----------------
--------------------------------------------------





--------------------------------------------------
-----------------PLAYBACK HISTORY-----------------
CREATE TABLE PlaybackHistory (
    PlaybackID INT IDENTITY PRIMARY KEY,
    UserID INT NOT NULL,
    PlaybackDate DATETIME DEFAULT GETDATE() NOT NULL,
    DurationPlayedSeconds INT NOT NULL,
	DeviceTypeID INT NOT NULL,
    MediaType NVARCHAR(15) NOT NULL,
    MediaID INT NOT NULL,

	CONSTRAINT CK_PlaybackHistory_PlaybackDate
        CHECK (PlaybackDate <= GETDATE()),
  	CONSTRAINT CK_PlaybackHistory_DurationPlayedSeconds 
  		CHECK (DurationPlayedSeconds >= 0),
    CONSTRAINT CK_PlaybackHistory_MediaType
        CHECK (MediaType IN ('SONG', 'EPISODE', 'AD')),
	
	CONSTRAINT FK_PlaybackHistory_Users 
  		FOREIGN KEY (UserID)
  		REFERENCES Users(UserID),
	CONSTRAINT FK_PlaybackHistory_DeviceTypes
  		FOREIGN KEY (DeviceTypeID)
  		REFERENCES DeviceTypes(DeviceTypeID)
);
GO


CREATE TABLE SongPlaybackDetails (
    PlaybackID INT PRIMARY KEY,
    SongID INT NOT NULL,

	CONSTRAINT FK_SongPlaybackDetails_PlaybackHistory
  		FOREIGN KEY (PlaybackID)
  		REFERENCES PlaybackHistory(PlaybackID),
    CONSTRAINT FK_PlaybackDetails_Songs 
  		FOREIGN KEY (SongID)
  		REFERENCES Songs(SongID)
);
GO


CREATE TABLE EpisodePlaybackDetails (
    PlaybackID INT PRIMARY KEY,
    EpisodeID INT NOT NULL,

	CONSTRAINT FK_EpisodePlaybackDetails_PlaybackHistory
  		FOREIGN KEY (PlaybackID)
  		REFERENCES PlaybackHistory(PlaybackID),
    CONSTRAINT FK_EpisodePlaybackDetails_PodcastEpisodes 
  		FOREIGN KEY (EpisodeID)
  		REFERENCES PodcastEpisodes(EpisodeID)
);
GO

CREATE TABLE AdPlaybackDetails (
    PlaybackID INT PRIMARY KEY,
    AdID INT NOT NULL,

	CONSTRAINT FK_AdPlaybackDetails_PlaybackHistory
  		FOREIGN KEY (PlaybackID)
  		REFERENCES PlaybackHistory(PlaybackID),
    CONSTRAINT FK_AdPlaybackDetails_Ads
  		FOREIGN KEY (AdID)
  		REFERENCES Ads(AdID)
);
GO
-----------------PLAYBACK HISTORY-----------------
--------------------------------------------------




--------------------------------------------------
--------------------INDEXES-----------------------
CREATE INDEX IDX_PlaybackHistory_UserID
ON PlaybackHistory (UserID);
GO

CREATE INDEX IDX_PlaybackHistory_PlaybackDate
ON PlaybackHistory (PlaybackDate);
GO

CREATE INDEX IDX_PlaybackHistory_DeviceTypeID
ON PlaybackHistory (DeviceTypeID);
GO

CREATE INDEX IDX_Songs_GenreID
ON Songs (GenreID);
GO

CREATE INDEX IDX_UserSubscriptions_UserID
ON UserSubscriptions (UserID);
GO

CREATE INDEX IDX_SongCreators_ArtistID
ON SongCreators (ArtistID);
GO

CREATE INDEX IDX_AlbumCreators_ArtistID
ON AlbumCreators (ArtistID);
GO
--------------------INDEXES-----------------------
--------------------------------------------------



------------------------------------------------
--------------------MEDIA-----------------------
CREATE TRIGGER TR_PlaybackHistory_InsertWithValidation
ON PlaybackHistory
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted i
        LEFT JOIN Songs s ON i.MediaID = s.SongID AND i.MediaType = 'SONG'
        LEFT JOIN PodcastEpisodes e ON i.MediaID = e.EpisodeID AND i.MediaType = 'EPISODE'
        LEFT JOIN Ads a ON i.MediaID = a.AdID AND i.MediaType = 'AD'
        WHERE 
            (i.MediaType = 'SONG' AND s.SongID IS NULL) OR
            (i.MediaType = 'EPISODE' AND e.EpisodeID IS NULL) OR
            (i.MediaType = 'AD' AND a.AdID IS NULL) OR

            (i.MediaType = 'SONG' AND i.DurationPlayedSeconds > s.DurationSeconds) OR
            (i.MediaType = 'EPISODE' AND i.DurationPlayedSeconds > e.DurationSeconds) OR
            (i.MediaType = 'AD' AND i.DurationPlayedSeconds <> a.DurationSeconds)
    )
    BEGIN
        RAISERROR ('Validation Error: Invalid MediaID for the specified type or DurationPlayedSeconds exceeds media length.', 16, 1);
        RETURN;
    END

    DECLARE @NewIDs TABLE (
        PlaybackID INT,
        MediaID INT,
        MediaType NVARCHAR(15)
    );

    INSERT INTO PlaybackHistory (UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID)
    OUTPUT inserted.PlaybackID, inserted.MediaID, inserted.MediaType INTO @NewIDs
    SELECT UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID
    FROM inserted;

    INSERT INTO SongPlaybackDetails (PlaybackID, SongID)
    SELECT PlaybackID, MediaID FROM @NewIDs WHERE MediaType = 'SONG';

    INSERT INTO EpisodePlaybackDetails (PlaybackID, EpisodeID)
    SELECT PlaybackID, MediaID FROM @NewIDs WHERE MediaType = 'EPISODE';

    INSERT INTO AdPlaybackDetails (PlaybackID, AdID)
    SELECT PlaybackID, MediaID FROM @NewIDs WHERE MediaType = 'AD';
END;
GO


CREATE TRIGGER TR_PlaybackHistory_UpdateStreamCounts
ON PlaybackHistory
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE s
    SET s.StreamCount = s.StreamCount + sub.CountAdded
    FROM Songs s
    JOIN (
        SELECT i.MediaID, COUNT(*) AS CountAdded
        FROM inserted i
        JOIN Songs s2 ON i.MediaID = s2.SongID
        WHERE i.MediaType = 'SONG'
          AND (i.DurationPlayedSeconds >= 30 
               OR i.DurationPlayedSeconds >= (s2.DurationSeconds * 0.5))
        GROUP BY i.MediaID
    ) sub ON s.SongID = sub.MediaID;

    UPDATE pe
    SET pe.StreamCount = pe.StreamCount + sub.CountAdded
    FROM PodcastEpisodes pe
    JOIN (
        SELECT i.MediaID, COUNT(*) AS CountAdded
        FROM inserted i
        JOIN PodcastEpisodes pe2 ON i.MediaID = pe2.EpisodeID
        WHERE i.MediaType = 'EPISODE'
          AND (i.DurationPlayedSeconds >= 300 
               OR i.DurationPlayedSeconds >= (pe2.DurationSeconds * 0.5))
        GROUP BY i.MediaID
    ) sub ON pe.EpisodeID = sub.MediaID;

    UPDATE a
    SET a.StreamCount = a.StreamCount + sub.CountAdded
    FROM Ads a
    JOIN (
        SELECT i.MediaID, COUNT(*) AS CountAdded
        FROM inserted i
        WHERE i.MediaType = 'AD'
        GROUP BY i.MediaID
    ) sub ON a.AdID = sub.MediaID;
END;
GO


CREATE TRIGGER TR_PodcastEpisodes_UpdateCount
ON PodcastEpisodes
AFTER INSERT, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        UPDATE p
        SET p.EpisodeCount = p.EpisodeCount + sub.NewEpisodes
        FROM Podcasts p
        JOIN (
            SELECT PodcastID, COUNT(*) AS NewEpisodes
            FROM inserted
            GROUP BY PodcastID
        ) sub ON p.PodcastID = sub.PodcastID;
    END
END;
GO
--------------------MEDIA-----------------------
------------------------------------------------



------------------------------------------------
----------------SUBSCRIPTIONS-------------------
CREATE TRIGGER TR_UserSubscriptions_InsertWithValidation
ON UserSubscriptions
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM UserSubscriptions us
        JOIN inserted i ON us.UserID = i.UserID
        WHERE us.IsActive = 1
    )
    BEGIN
        RAISERROR ('Validation Error: User already has an active subscription.', 16, 1);
        RETURN;
    END

    INSERT INTO UserSubscriptions (UserSubscriptionID, UserID, SubscriptionTypeID, StartDate)
    SELECT UserSubscriptionID, UserID, SubscriptionTypeID, StartDate
    FROM inserted;
END;
GO


CREATE TRIGGER TR_UserSubscriptions_SetEndDate
ON UserSubscriptions
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE us
    SET 
        us.EndDate = DATEADD(MONTH, st.DurationMonths, i.StartDate),
        us.IsActive = 1
    FROM UserSubscriptions us
    JOIN inserted i ON us.UserSubscriptionID = i.UserSubscriptionID
    JOIN SubscriptionTypes st ON i.SubscriptionTypeID = st.SubscriptionTypeID;
END;
GO
----------------SUBSCRIPTIONS-------------------
------------------------------------------------



------------------------------------------------
--------------------MEDIA-----------------------
CREATE PROCEDURE StreamSong
    @UserID INT,
    @SongID INT,
    @DeviceTypeID INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PlaybackHistory (UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID)
    SELECT 
        @UserID, 
        GETDATE(), 
        s.DurationSeconds, 
        @DeviceTypeID, 
        'SONG', 
        s.SongID
    FROM Songs s
    WHERE s.SongID = @SongID;
END;
GO


CREATE PROCEDURE StreamAlbum
    @UserID INT,
    @AlbumID INT,
    @DeviceTypeID INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PlaybackHistory (UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID)
    SELECT 
        @UserID, 
        GETDATE(), 
        s.DurationSeconds, 
        @DeviceTypeID, 
        'SONG', 
        s.SongID
    FROM Songs s
    WHERE AlbumID = @AlbumID;
END;
GO


CREATE PROCEDURE StreamDiscography
    @UserID INT,
    @ArtistID INT,
    @DeviceTypeID INT = 1
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO PlaybackHistory (UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID)
    SELECT 
        @UserID, 
        GETDATE(), 
        s.DurationSeconds, 
        @DeviceTypeID, 
        'SONG', 
        s.SongID
    FROM Songs s
    JOIN SongCreators sc ON s.SongID = sc.SongID
    WHERE sc.ArtistID = @ArtistID;
END;
GO


CREATE OR ALTER PROCEDURE LikeAlbum
    @UserID INT,
    @AlbumID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO SongLikes (UserID, SongID, LikeDate)
    SELECT @UserID, SongID, GETDATE()
    FROM Songs
    WHERE AlbumID = @AlbumID
        AND SongID NOT IN (
            SELECT SongID FROM SongLikes WHERE UserID = @UserID
        );
END;
GO


CREATE OR ALTER PROCEDURE FollowLabel
    @UserID INT,
    @LabelID INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO FollowsArtists (UserID, ArtistID, FollowDate)
    SELECT @UserID, ArtistID, GETDATE()
    FROM Artists
    WHERE LabelID = @LabelID
        AND ArtistID NOT IN (
            SELECT ArtistID FROM FollowsArtists WHERE UserID = @UserID
        );
END;
GO
--------------------MEDIA-----------------------
------------------------------------------------




------------------------------------------------
---------------UPDATE ISACTIVE------------------

-- this procedure should be executed everyday at 00:00

CREATE OR ALTER PROCEDURE UpdateIsActive
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE UserSubscriptions
    SET IsActive = 0
    WHERE IsActive = 1 
        AND EndDate < CAST(GETDATE() AS DATE);

END;
GO
---------------UPDATE ISACTIVE------------------
-----------------------------------------------




CREATE FUNCTION GetUserMostStreamedGenre (@UserID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @Result NVARCHAR(100);
    SELECT TOP 1 @Result = g.Name
    FROM PlaybackHistory ph
    JOIN SongPlaybackDetails spd ON ph.PlaybackID = spd.PlaybackID
    JOIN Songs s ON spd.SongID = s.SongID
    JOIN Genres g ON s.GenreID = g.GenreID
    WHERE ph.UserID = @UserID
    GROUP BY g.GenreID, g.Name
    ORDER BY COUNT(*) DESC;
    RETURN @Result;
END;
GO


CREATE FUNCTION GetUserMostStreamedArtist (@UserID INT)
RETURNS NVARCHAR(150)
AS
BEGIN
    DECLARE @Result NVARCHAR(150);
    SELECT TOP 1 @Result = a.Name
    FROM PlaybackHistory ph
    JOIN SongPlaybackDetails spd ON ph.PlaybackID = spd.PlaybackID
    JOIN SongCreators sc ON spd.SongID = sc.SongID
    JOIN Artists a ON sc.ArtistID = a.ArtistID
    WHERE ph.UserID = @UserID
    GROUP BY a.ArtistID, a.Name
    ORDER BY COUNT(*) DESC;
    RETURN @Result;
END;
GO


CREATE FUNCTION GetUserMostStreamedAlbum (@UserID INT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @Result NVARCHAR(200);
    SELECT TOP 1 @Result = alb.Title
    FROM PlaybackHistory ph
    JOIN SongPlaybackDetails spd ON ph.PlaybackID = spd.PlaybackID
    JOIN Songs s ON spd.SongID = s.SongID
    JOIN Albums alb ON s.AlbumID = alb.AlbumID
    WHERE ph.UserID = @UserID
        AND alb.AlbumType = 'ALBUM'
    GROUP BY alb.AlbumID, alb.Title
    ORDER BY COUNT(*) DESC;
    RETURN @Result;
END;
GO


CREATE FUNCTION GetUserMostStreamedSong (@UserID INT)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @Result NVARCHAR(200);
    SELECT TOP 1 @Result = s.Title
    FROM PlaybackHistory ph
    JOIN SongPlaybackDetails spd ON ph.PlaybackID = spd.PlaybackID
    JOIN Songs s ON spd.SongID = s.SongID
    WHERE ph.UserID = @UserID
    GROUP BY s.SongID, s.Title
    ORDER BY COUNT(*) DESC;
    RETURN @Result;
END;
GO


CREATE FUNCTION GetUserMostStreamedPodcast (@UserID INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Result NVARCHAR(50);
    SELECT TOP 1 @Result = p.Name
    FROM PlaybackHistory ph
    JOIN EpisodePlaybackDetails epd ON ph.PlaybackID = epd.PlaybackID
    JOIN PodcastEpisodes pe ON epd.EpisodeID = pe.EpisodeID
    JOIN Podcasts p ON pe.PodcastID = p.PodcastID
    WHERE ph.UserID = @UserID
    GROUP BY p.PodcastID, p.Name
    ORDER BY COUNT(*) DESC;
    RETURN @Result;
END;
GO


CREATE FUNCTION GetUserMostStreamedPodcastCategory (@UserID INT)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @Result NVARCHAR(50);
    SELECT TOP 1 @Result = pc.Name
    FROM PlaybackHistory ph
    JOIN EpisodePlaybackDetails epd ON ph.PlaybackID = epd.PlaybackID
    JOIN PodcastEpisodes pe ON epd.EpisodeID = pe.EpisodeID
    JOIN Podcasts p ON pe.PodcastID = p.PodcastID
    JOIN PodcastCategories pc ON p.CategoryID = pc.CategoryID
    WHERE ph.UserID = @UserID
    GROUP BY pc.CategoryID, pc.Name
    ORDER BY COUNT(*) DESC;
    RETURN @Result;
END;
GO


CREATE FUNCTION GetUserListeningStats
(
    @UserID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        CAST(ISNULL(SUM(ph.DurationPlayedSeconds) / 60.0, 0) AS DECIMAL(10, 1)) AS TotalListeningMinutes,
        CAST(ISNULL(SUM(CASE WHEN ph.MediaType = 'SONG' THEN DurationPlayedSeconds ELSE 0 END) / 60.0, 0) AS DECIMAL(10, 1)) AS SongsMinutes,
        CAST(ISNULL(SUM(CASE WHEN ph.MediaType = 'EPISODE' THEN DurationPlayedSeconds ELSE 0 END) / 60.0, 0) AS DECIMAL(10, 1)) AS PodcastsMinutes,
        CAST(ISNULL(SUM(CASE WHEN ph.MediaType = 'AD' THEN DurationPlayedSeconds ELSE 0 END) / 60.0, 0) AS DECIMAL(10, 1)) AS AdsMinutes
    FROM PlaybackHistory ph
    WHERE UserID = @UserID
);
GO


CREATE FUNCTION GetArtistTotalStreams (@ArtistID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalStreams INT;

    SELECT @TotalStreams = COUNT(ph.PlaybackID)
    FROM PlaybackHistory ph
    JOIN SongPlaybackDetails spd ON ph.PlaybackID = spd.PlaybackID
    JOIN SongCreators sc ON spd.SongID = sc.SongID
    WHERE sc.ArtistID = @ArtistID;

    RETURN ISNULL(@TotalStreams, 0);
END;
GO


CREATE FUNCTION GetPodcastTotalStreams (@PodcastID INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalStreams INT;

    SELECT @TotalStreams = COUNT(ph.PlaybackID)
    FROM PlaybackHistory ph
    JOIN EpisodePlaybackDetails epd ON ph.PlaybackID = epd.PlaybackID
    JOIN PodcastEpisodes pe ON epd.EpisodeID = pe.EpisodeID
    WHERE pe.PodcastID = @PodcastID;

    RETURN ISNULL(@TotalStreams, 0);
END;
GO


CREATE VIEW VW_SongLibrary AS
SELECT 
    a.ArtistID,
    a.Name AS ArtistName,
    alb.AlbumType,
    alb.Title AS AlbumTitle,
    s.Title AS SongTitle,
    s.DurationSeconds,
    g.Name AS GenreName,
    s.ReleaseDate,
    s.StreamCount
FROM Artists a
JOIN SongCreators sc ON a.ArtistID = sc.ArtistID
JOIN Songs s ON sc.SongID = s.SongID
LEFT JOIN Albums alb ON s.AlbumID = alb.AlbumID
LEFT JOIN Genres g ON s.GenreID = g.GenreID
GO


CREATE VIEW VW_ActivePremiumUsers
AS
SELECT 
    u.UserID AS UserID,
    u.Username AS Username,
    u.Email AS Email,
    st.Name AS CurrentSubscriptionType,
    us.StartDate AS StartDate,
    us.EndDate AS EndDate
FROM Users u
JOIN UserSubscriptions us 
    ON u.UserID = us.UserID
JOIN SubscriptionTypes st 
    ON us.SubscriptionTypeID = st.SubscriptionTypeID
WHERE us.IsActive = 1 
GO


CREATE VIEW VW_PlaybacksByDevice
AS
SELECT 
    dt.Name AS DeviceName,
    COUNT(ph.PlaybackID) AS PlaybackCount
FROM PlaybackHistory ph
JOIN DeviceTypes dt 
    ON ph.DeviceTypeID = dt.DeviceTypeID
GROUP BY dt.Name;
GO


CREATE VIEW VW_PlaybacksByGenre
AS
SELECT 
    g.Name AS GenreName,
    COUNT(ph.PlaybackID) AS PlaybackCount
FROM PlaybackHistory ph
JOIN SongPlaybackDetails spd 
    ON ph.PlaybackID = spd.PlaybackID
JOIN Songs s 
    ON spd.SongID = s.SongID
JOIN Genres g 
    ON s.GenreID = g.GenreID
GROUP BY g.Name;
GO


CREATE VIEW VW_PlaybacksByPodcastCategory
AS
SELECT 
    pc.Name AS CategoryName,
    COUNT(ph.PlaybackID) AS PlaybackCount
FROM PlaybackHistory ph
JOIN EpisodePlaybackDetails epd 
    ON ph.PlaybackID = epd.PlaybackID
JOIN PodcastEpisodes pe 
    ON epd.EpisodeID = pe.EpisodeID
JOIN Podcasts p 
    ON pe.PodcastID = p.PodcastID
JOIN PodcastCategories pc 
    ON p.CategoryID = pc.CategoryID
GROUP BY pc.Name;
GO



INSERT INTO Languages (LanguageID, Name) VALUES
(1, 'Polish'),
(2, 'English'),
(3, 'German'),
(4, 'Spanish'),
(5, 'Portuguese'),
(6, 'Russian'),
(7, 'Japanese'),
(8, 'Italian');


INSERT INTO Countries (CountryID, Name) VALUES
(1, 'Poland'),
(2, 'Germany'),
(3, 'United States'),
(4, 'United Kingdom'),
(5, 'Spain'),
(6, 'Brazil'),
(7, 'Portugal'),
(8, 'Italy'),
(9, 'Russia'),
(10, 'Japan'),
(11, 'Mexico'),
(12, 'Argentina'),
(13, 'Canada'),
(14, 'Australia'),
(15, 'Austria'),
(16, 'Switzerland');


INSERT INTO SubscriptionTypes (SubscriptionTypeID, Name, Price, DurationMonths) VALUES
(1, 'Monthly', 15, 1),
(2, 'Quarterly', 35, 3),
(3, 'Semi-annual', 60, 6),
(4, 'Annual', 100, 12);


INSERT INTO DeviceTypes (DeviceTypeID, Name) VALUES
(1, 'Phone'),
(2, 'TV'),
(3, 'Desktop'),
(4, 'Car'),
(5, 'Gaming Console');


INSERT INTO Labels (LabelID, Name, CountryID, ContactEmail) VALUES
(1, 'Griselda Records', 3, 'contact@griselda.com'),
(2, 'Sony Music Entertainment', 3, 'global@sonymusic.com'),
(4, 'Universal Music Group', 3, 'legal@umg.com'),
(5, 'Atlantic Records', 3, 'contact@atlanticrecords.com'),
(6, 'Avex Group', 10, 'info@avex.jp'),
(7, 'Rimas Entertainment', 11, 'info@rimasmusic.com'),
(8, 'Opium', 3, 'contact@opium.com'),
(9, 'Warner Records', 3, 'contact@warnerrecords.com');


INSERT INTO Artists (ArtistID, Name, CountryID, LabelID) VALUES
(1, 'Westside Gunn', 3, 1),
(2, 'Benny The Butcher', 3, 1),
(3, 'Maneskin', 8, 2),
(4, 'Margaret', 1, 2),
(5, 'Sting', 4, 4),
(6, 'Justin Bieber', 13, 4),
(7, 'Lil Uzi Vert', 3, 5),
(8, 'Cardi B', 3, 5),
(9, 'Ayumi Hamasaki', 10, 6),
(10, 'Daichi Miura', 10, 6),
(11, 'Bad Bunny', 11, 7),
(12, 'Arcangel', 11, 7),
(13, 'Playboi Carti', 3, 8),
(14, 'Ken Carson', 3, 8),
(15, 'Destroy Lonely', 3, 8),
(16, 'Homixide Gang', 3, 8),
(17, 'Addison Rae', 3, 2),
(18, 'PinkPantheress', 4, 9);


INSERT INTO Producers (ProducerID, Name, CountryID) VALUES
(1, 'The Alchemist', 3),
(2, 'Daringer', 3),
(3, 'Max Martin', 13),
(4, 'Fabrizio Ferraguzzo', 8),
(5, 'Hugh Padgham', 4),
(6, 'Metro Boomin', 3),
(7, 'Murda Beatz', 13),
(8, 'Tainy', 11),
(9, 'Yasutaka Nakata', 10),
(10, 'Mark Ronson', 4),
(11, 'F1lthy', 3),
(12, 'Cardo', 3),
(13, 'Bnyx', 3);


INSERT INTO Genres (GenreID, Name, PopularityFromYear, PopularityToYear) VALUES
(1, 'Hip-Hop', 1973, 2026),
(2, 'Pop', 1950, 2026),
(3, 'Rock', 1950, 2015),
(4, 'Trap', 2010, 2026),
(5, 'R&B', 1990, 2026),
(6, 'J-Pop', 1980, 2026),
(7, 'Dance Pop', 1995, 2026),
(8, 'Reggaeton', 1990, 2026),
(9, 'Latin Pop', 2015, 2026);


INSERT INTO Albums (AlbumID, Title, ReleaseDate, AlbumType) VALUES
(1, 'Pray for Paris', '2020-04-17', 'ALBUM'),
(2, 'Lotto', '2020-03-27', 'SINGLE'),
(3, 'Tana Talk 4', '2022-03-11', 'ALBUM'),
(4, 'The Plugs I Met', '2019-06-21', 'ALBUM'),
(5, 'Rush!', '2023-01-20', 'ALBUM'),
(6, 'Mammamia', '2021-10-08', 'SINGLE'),
(7, 'Supermodel', '2022-05-13', 'SINGLE'),
(8, 'Add the Blonde', '2014-08-27', 'ALBUM'),
(9, 'Cool Me Down', '2016-02-19', 'SINGLE'),
(10, 'Thank You Very Much', '2013-02-21', 'SINGLE'),
(11, 'The Soul Cages', '1991-01-17', 'ALBUM'),
(12, 'The Bridge', '2021-11-19', 'ALBUM'),
(13, 'Desert Rose', '1999-12-04', 'SINGLE'),
(14, 'Purpose', '2015-11-13', 'ALBUM'),
(15, 'Justice', '2021-03-19', 'ALBUM'),
(16, 'Stay', '2021-07-09', 'SINGLE'),
(17, 'Luv Is Rage 2', '2017-08-25', 'ALBUM'),
(18, 'Pink Tape', '2023-06-30', 'ALBUM'),
(19, 'Just Wanna Rock', '2022-10-17', 'SINGLE'),
(20, 'Invasion of Privacy', '2018-04-06', 'ALBUM'),
(21, 'Bodak Yellow', '2017-06-16', 'SINGLE'),
(22, 'LOVEppears', '1999-11-10', 'ALBUM'),
(23, 'SEASONS', '2000-06-07', 'SINGLE'),
(24, 'FEVER', '2015-09-02', 'ALBUM'),
(25, 'music', '2015-06-17', 'SINGLE'),
(26, 'YHLQMDLG', '2020-02-29', 'ALBUM'),
(27, 'Un Verano Sin Ti', '2022-05-06', 'ALBUM'),
(28, 'Dákiti', '2020-10-30', 'SINGLE'),
(29, 'Ares', '2018-07-13', 'ALBUM'),
(30, 'Historias de un Capricornio', '2019-12-20', 'ALBUM'),
(31, 'All Red', '2024-09-13', 'SINGLE'),
(32, 'Whole Lotta Red', '2020-12-25', 'ALBUM'),
(33, 'Die Lit', '2018-05-11', 'ALBUM'),
(34, 'Music', '2025-03-14', 'ALBUM'),
(35, 'If Looks Could Kill', '2023-05-05', 'ALBUM'),
(36, 'NO STYLIST', '2022-08-12', 'ALBUM'),
(37, 'X', '2022-07-08', 'ALBUM'),
(38, 'More Chaos', '2023-10-13', 'ALBUM'),
(39, 'Homixide Lifestyle', '2022-11-22', 'ALBUM'),
(40, 'Snot or Not', '2023-04-27', 'ALBUM'),
(41, 'Addison', '2023-08-18', 'ALBUM'),
(42, 'Take Me Home', '2022-12-16', 'SINGLE'),
(43, 'Heaven Knows', '2023-11-10', 'ALBUM'),
(44, 'Fancy That', '2025-05-09', 'ALBUM');

INSERT INTO Songs (SongID, Title, DurationSeconds, IsExplicit, ReleaseDate, AlbumID, GenreID, ProducerID) VALUES
(1, 'George Bondo', 254, 1, '2020-04-17', 1, 1, 2),
(2, '327', 347, 1, '2020-04-17', 1, 1, 1),
(3, 'French Toast', 286, 1, '2020-04-17', 1, 1, 2),
(4, 'Allah Sent Me', 290, 1, '2020-04-17', 1, 1, 2),
(5, 'Euro Step', 108, 1, '2020-04-17', 1, 1, 2),
(6, 'Lotto', 212, 1, '2020-03-27', 2, 1, 2),

(7, 'Johnny Ps Caddy', 225, 1, '2022-03-11', 3, 1, 1),
(8, 'Back 2x', 201, 1, '2022-03-11', 3, 1, 2),
(9, '10 More Commandments', 234, 1, '2022-03-11', 3, 1, 2),
(10, 'Tyson vs Ali', 198, 1, '2022-03-11', 3, 1, 2),
(11, 'Uncle Bun', 182, 1, '2022-03-11', 3, 1, 1),
(12, 'Crowns for Kings', 223, 1, '2019-06-21', 4, 1, 1),
(13, 'Dirty Harry', 214, 1, '2019-06-21', 4, 1, 1),
(14, '5 to 50', 238, 1, '2019-06-21', 4, 1, 1),
(15, 'Sunday School', 201, 1, '2019-06-21', 4, 1, 1),

(16, 'Own My Mind', 191, 0, '2023-01-20', 5, 3, 4),
(17, 'Gossip', 168, 0, '2023-01-20', 5, 3, 4),
(18, 'Timezone', 179, 0, '2023-01-20', 5, 3, 4),
(19, 'Baby Said', 164, 0, '2023-01-20', 5, 3, 4),
(20, 'The Loneliest', 247, 0, '2023-01-20', 5, 3, 4),
(21, 'Mammamia', 186, 0, '2021-10-08', 6, 3, 4),
(22, 'Supermodel', 148, 0, '2022-05-13', 7, 3, 4),

(23, 'Wasted', 190, 0, '2014-08-27', 8, 2, 3),
(24, 'Heartbeat', 199, 0, '2014-08-27', 8, 2, 3),
(25, 'Broke But Happy', 222, 0, '2014-08-27', 8, 2, 3),
(26, 'Too Little of Happy', 186, 0, '2014-08-27', 8, 2, 3),
(27, 'Cool Me Down', 179, 0, '2016-02-19', 9, 2, 3),
(28, 'Thank You Very Much', 190, 0, '2013-02-21', 10, 2, 3),

(29, 'Mad About You', 233, 0, '1991-01-17', 11, 3, 5),
(30, 'All This Time', 294, 0, '1991-01-17', 11, 3, 5),
(31, 'Island of Souls', 401, 0, '1991-01-17', 11, 3, 5),
(32, 'Why Should I Cry For You', 286, 0, '1991-01-17', 11, 3, 5),
(33, 'Rushing Water', 197, 0, '2021-11-19', 12, 3, 5),
(34, 'If Its Love', 194, 0, '2021-11-19', 12, 3, 5),
(35, 'The Bridge', 153, 0, '2021-11-19', 12, 3, 5),
(36, 'Loving You', 264, 0, '2021-11-19', 12, 3, 5),
(37, 'Desert Rose', 285, 0, '1999-12-04', 13, 2, 5),

(38, 'Sorry', 200, 0, '2015-11-13', 14, 2, 3),
(39, 'Love Yourself', 233, 0, '2015-11-13', 14, 2, 3),
(40, 'What Do You Mean', 205, 0, '2015-11-13', 14, 2, 3),
(41, 'Company', 208, 0, '2015-11-13', 14, 2, 3),
(42, 'Peaches', 198, 1, '2021-03-19', 15, 2, 3),
(43, 'Ghost', 153, 0, '2021-03-19', 15, 2, 3),
(44, 'Hold On', 170, 0, '2021-03-19', 15, 2, 3),
(45, 'Lonely', 149, 0, '2021-03-19', 15, 2, 3),
(46, 'Stay', 141, 0, '2021-07-09', 16, 2, 3),

(47, 'XO TOUR Llif3', 180, 1, '2017-08-25', 17, 4, 1),
(48, 'The Way Life Goes', 221, 1, '2017-08-25', 17, 4, 2),
(49, 'Sauce It Up', 207, 1, '2017-08-25', 17, 4, 2),
(50, 'Flooded The Face', 192, 1, '2023-06-30', 18, 4, 1),
(51, 'Nakamura', 210, 1, '2023-06-30', 18, 4, 2),
(52, 'Fire Alarm', 191, 1, '2023-06-30', 18, 4, 2),
(53, 'Just Wanna Rock', 122, 0, '2022-10-17', 19, 4, 2),

(54, 'I Like It', 253, 1, '2018-04-06', 20, 1, 3),
(55, 'Be Careful', 211, 0, '2018-04-06', 20, 1, 3),
(56, 'Bartier Cardi', 194, 1, '2018-04-06', 20, 1, 3),
(57, 'Bodak Yellow', 223, 1, '2017-06-16', 21, 1, 3),

(58, 'Boys & Girls', 231, 0, '1999-11-10', 22, 7, 4),
(59, 'Appears', 338, 0, '1999-11-10', 22, 7, 4),
(60, 'SEASONS', 347, 0, '2000-06-07', 23, 7, 4),

(61, 'FEVER', 238, 0, '2015-09-02', 24, 6, 4),
(62, 'Anchor', 256, 0, '2015-09-02', 24, 6, 4),
(63, 'music', 242, 0, '2015-06-17', 25, 6, 4),

(64, 'Yo Perreo Sola', 172, 0, '2020-02-29', 26, 8, 1),
(65, 'Safaera', 295, 1, '2020-02-29', 26, 8, 1),
(66, 'La Difícil', 163, 0, '2020-02-29', 26, 8, 1),
(67, 'Moscow Mule', 245, 0, '2022-05-06', 27, 8, 1),
(68, 'Me Porto Bonito', 178, 1, '2022-05-06', 27, 8, 1),
(69, 'Tití Me Preguntó', 244, 1, '2022-05-06', 27, 8, 1),
(70, 'Dákiti', 205, 0, '2020-10-30', 28, 8, 1),

(71, 'Atmósfera', 254, 1, '2018-07-13', 29, 9, 2),
(72, 'Se Supone', 208, 1, '2018-07-13', 29, 9, 2),
(73, 'Original', 246, 1, '2018-07-13', 29, 9, 2),
(74, 'Mi Testimonio', 285, 1, '2019-12-20', 30, 9, 2),
(75, 'Al Volante', 200, 1, '2019-12-20', 30, 9, 2),
(76, 'Rehén', 175, 1, '2019-12-20', 30, 9, 2),
(77, 'Ponte Bonita', 193, 1, '2019-12-20', 30, 9, 2),
(78, 'Sigues con él', 210, 1, '2019-12-20', 30, 9, 2),

(79, 'ALL RED', 148, 1, '2024-09-13', 31, 1, 11),
(80, 'Go2DaMoon', 119, 1, '2020-12-25', 32, 1, 12),
(81, 'Stop Breathing', 218, 1, '2020-12-25', 32, 1, 11),
(82, 'New N3on', 116, 1, '2020-12-25', 32, 1, 11),
(83, 'Rockstar Made', 193, 1, '2020-12-25', 32, 1, 11),
(84, 'M3tamorphosis', 312, 1, '2020-12-25', 32, 1, 12),
(85, 'R.I.P.', 192, 1, '2018-05-11', 33, 1, 11),
(86, 'Old Money', 135, 1, '2018-05-11', 33, 1, 11),
(87, 'Poke It Out', 269, 1, '2018-05-11', 33, 1, 11),
(88, 'Shoota', 153, 1, '2018-05-11', 33, 1, 13),
(89, 'No Time', 219, 1, '2018-05-11', 33, 1, 13),
(90, 'OVERLY', 180, 1, '2025-03-14', 34, 1, 13),
(91, 'K POP', 175, 1, '2025-03-14', 34, 1, 13),
(92, 'HBA', 210, 1, '2025-03-14', 34, 1, 12),
(93, 'FINE SHIT', 165, 1, '2025-03-14', 34, 1, 11),
(94, '2024', 129, 1, '2025-03-14', 34, 1, 12),

(95, 'chris paul', 154, 1, '2023-05-05', 35, 1, 13),
(96, 'if looks could kill', 187, 1, '2023-05-05', 35, 1, 13),
(97, 'new new', 142, 1, '2023-05-05', 35, 1, 11),
(98, 'promo', 161, 1, '2023-05-05', 35, 1, 11),
(99, 'blitz', 128, 1, '2023-05-05', 35, 1, 11),
(100, 'NOSTYLIST', 174, 1, '2022-08-12', 36, 1, 11),
(101, 'JETLGGD', 152, 1, '2022-08-12', 36, 1, 11),
(102, '<3MYGNG', 148, 1, '2022-08-12', 36, 1, 11),
(103, 'ONTHETABLE', 160, 1, '2022-08-12', 36, 1, 11),

(104, 'New', 155, 1, '2022-07-08', 37, 1, 11),
(105, 'Gems', 142, 1, '2022-07-08', 37, 1, 11),
(106, 'Shoot', 168, 1, '2022-07-08', 37, 1, 11),
(107, 'MDMA (feat. Destroy Lonely)', 195, 1, '2022-07-08', 37, 1, 11),
(108, 'Delinquent (feat. Homixide Gang)', 172, 1, '2022-07-08', 37, 1, 11),
(109, 'Money Spread', 162, 1, '2023-10-13', 38, 1, 11),
(110, '2000', 145, 1, '2023-10-13', 38, 1, 11),
(111, 'Ghoul', 158, 1, '2023-10-13', 38, 1, 11),
(112, 'Off The Meter', 140, 1, '2023-10-13', 38, 1, 11),

(113, 'Lifestyle', 145, 1, '2022-11-22', 39, 1, 11),
(114, 'V-Friends', 132, 1, '2022-11-22', 39, 1, 11),
(115, 'Stunt', 128, 1, '2022-11-22', 39, 1, 11),
(116, 'Homixide Language', 150, 1, '2023-04-27', 40, 1, 11),
(117, 'Uzi Work', 138, 1, '2023-04-27', 40, 1, 11),

(118, 'Aquamarine', 165, 0, '2023-08-18', 41, 2, 3),
(119, 'In The Rain', 178, 0, '2023-08-18', 41, 2, 3),
(120, 'High Fashion', 155, 0, '2023-08-18', 41, 2, 3),

(121, 'Take Me Home', 145, 0, '2022-12-16', 42, 7, 4),
(122, 'Tonight', 162, 0, '2025-05-09', 44, 7, 4),
(123, 'Girl Like Me', 158, 0, '2025-05-09', 44, 7, 4),
(124, 'Stars', 170, 0, '2025-05-09', 44, 7, 4),
(125, 'True Romance', 136, 0, '2023-11-10', 43, 4, 7),
(126, 'Feelings', 150, 0, '2023-11-10', 43, 4, 7),
(127, 'Capable of love', 223, 0, '2023-11-10', 43, 4, 7);


INSERT INTO SongCreators (SongID, ArtistID) VALUES
(1,1),(2,1),(3,1),(4,1),(5,1),(6,1),
(7,2),(8,2),(9,2),(10,2),(11,2),(12,2),(13,2),(14,2),(15,2),
(16,3),(17,3),(18,3),(19,3),(20,3),(21,3),(22,3),
(23,4),(24,4),(25,4),(26,4),(27,4),(28,4),
(29,5),(30,5),(31,5),(32,5),(33,5),(34,5),(35,5),(36,5),(37,5),
(38,6),(39,6),(40,6),(41,6),(42,6),(43,6),(44,6),(45,6),(46,6),
(47,7),(48,7),(49,7),(50,7),(51,7),(52,7),(53,7),
(54,8),(55,8),(56,8),(57,8),
(58,9),(59,9),(60,9),
(61,10),(62,10),(63,10),
(64,11),(65,11),(66,11),(67,11),(68,11),(69,11),(70,11),
(71,12),(72,12),(73,12),(74,12),(75,12),(76,12),(77,12),(78,12),
(79,13),(80,13),(81,13),(82,13),(83,13),(84,13),(85,13),(86,13),(87,13),(88,13),(89,13),(90,13),(91,13),(92,13),(93,13),(94,13),
(95,15),(96,15),(97,15),(98,15),(99,15),(100,15),(101,15),(102,15),(103,15),
(104,14),(105,14),(106,14),
(107,14),(107,15),
(108,14),(108,16),
(109,14),(110,14),(111,14),(112,14),
(113,16),(114,16),(115,16),(116,16),(117,16),
(118,17),(119,17),(120,17),
(121,18),(122,18),(123,18),(124,18), (125, 18), (126, 18), (127, 18);


INSERT INTO AlbumCreators (AlbumID, ArtistID) VALUES
(1, 1),(2, 1),
(3, 2),(4, 2),
(5, 3),(6, 3),(7, 3),
(8, 4),(9, 4),(10, 4),
(11, 5),(12, 5),(13, 5),
(14, 6),(15, 6),(16, 6),
(17, 7),(18, 7),(19, 7),
(20, 8),(21, 8),
(22, 9),(23, 9),
(24, 10),(25, 10),
(26, 11),(27, 11),(28, 11),
(29, 12),(30, 12),
(31, 13),(32, 13),(33, 13),(34, 13),
(35, 15),(36, 15),
(37, 14),(38, 14),
(39, 16),(40, 16),
(41, 17),
(42, 18),(43, 18),(44, 18);


INSERT INTO PodcastCategories (CategoryID, Name) VALUES
(1, 'True Crime'),
(2, 'Technology'),
(3, 'Comedy'),
(4, 'Business'),
(5, 'Health'),
(6, 'Sports'),
(7, 'Education'),
(8, 'Music'),
(9, 'Science');


INSERT INTO Podcasts (PodcastID, Name, CategoryID, LanguageID) VALUES
(1, 'Kryminatorium', 1, 1),
(2, 'Lex Fridman Podcast', 2, 2),
(3, 'The Joe Rogan Experience', 3, 2),
(4, 'Darknet Diaries', 2, 2),
(5, 'Huberman Lab', 5, 2),
(6, 'The Tim Ferriss Show', 4, 2),
(7, 'No Such Thing As A Fish', 3, 2),
(8, 'Raport o stanie świata', 7, 1),
(9, 'Nauka To Lubię', 9, 1),
(10, 'Unfiltered Urban Legends', 3, 2),
(11, 'The Angler''s Mindset', 6, 2);


INSERT INTO PodcastEpisodes (EpisodeID, PodcastID, Title, DurationSeconds, ReleaseDate) VALUES
(1, 1, 'Zbrodnia na zamku', 2400, '2023-10-01'),
(2, 1, 'Tajemnica szafy', 2150, '2023-10-08'),
(3, 1, 'Ucieczka z wiezienia', 2700, '2023-10-15'),
(4, 1, 'Nierozwiazana sprawa', 2300, '2023-10-22'),
(5, 1, 'Sladami mordercy', 2550, '2023-10-29'),

(6, 2, 'Elon Musk on Mars', 7200, '2023-11-01'),
(7, 2, 'Sam Altman and OpenAI', 5400, '2023-11-10'),
(8, 2, 'The Future of Robotics', 6100, '2023-11-15'),
(9, 2, 'Physics of the Universe', 6800, '2023-11-20'),
(10, 2, 'History of Humanity', 5900, '2023-11-25'),

(11, 3, 'Duncan Trussell Returns', 10800, '2023-12-01'),
(12, 3, 'Health and Longevity', 9200, '2023-12-05'),
(13, 3, 'Comedy in LA', 8500, '2023-12-10'),
(14, 3, 'Deep Sea Exploration', 11200, '2023-12-15'),
(15, 3, 'The Art of Fighting', 7800, '2023-12-20'),

(16, 4, 'Xbox Underground', 3600, '2023-09-15'),
(17, 4, 'The Beirut Bank Job', 4200, '2023-09-29'),
(18, 4, 'Mariposa Botnet', 3900, '2023-10-13'),

(19, 5, 'How to Improve Sleep', 7200, '2023-10-02'),
(20, 5, 'The Science of Focus', 6800, '2023-10-16'),
(21, 5, 'Optimizing Hormones', 7500, '2023-10-30'),

(22, 6, 'Tools of Top Performers', 5400, '2023-09-20'),
(23, 6, 'Building Wealth', 6000, '2023-10-04'),
(24, 6, 'Learning Faster', 5700, '2023-10-18'),

(25, 7, 'The Fish That Fell From Space', 2400, '2023-09-22'),
(26, 7, 'Facts That Should Not Exist', 2500, '2023-10-06'),
(27, 7, 'Ridiculous World Records', 2600, '2023-10-20'),

(28, 8, 'Bliski Wschod po nowemu', 3600, '2023-09-25'),
(29, 8, 'Europa w kryzysie', 3900, '2023-10-09'),
(30, 8, 'Globalna polityka USA', 4200, '2023-10-23'),

(31, 9, 'Czy AI mysli?', 1800, '2023-09-18'),
(32, 9, 'Tajemnice kosmosu', 2100, '2023-10-02'),
(33, 9, 'Jak dziala mozg', 2000, '2023-10-16'),

(34, 10, 'My Baby Mama is a Loser', 2850, '2024-01-10'),
(35, 10, 'The Lock on the Juice Box', 3120, '2024-01-17'),
(36, 10, 'The DNA Test That Broke the Block', 3400, '2024-01-24'),

(37, 11, 'Patience and Peace: Why Fishing is Therapy', 2700, '2024-02-01'),
(38, 11, 'The Thrill of the Catch: Adrenaline on the Water', 3150, '2024-02-08'),
(39, 11, 'Conservation and Community: Protecting our Rivers', 2900, '2024-02-15');


INSERT INTO Advertisers (AdvertiserID, Name, CountryID) VALUES
(1, 'Coca-Cola Global', 3),
(2, 'Allegro Polska', 1),
(3, 'Nike Inc.', 3),
(4, 'Spotify AB', 16),
(5, 'Samsung Electronics', 10),
(6, 'McDonald''s Corporation', 3),
(7, 'Red Bull GmbH', 15),
(8, 'Winiary', 1),
(9, 'Browar Perla', 1);


INSERT INTO Ads (AdID, AdvertiserID, Title, DurationSeconds) VALUES
(1, 1, 'Taste the Feeling - Summer Edit', 30),
(2, 1, 'Holidays are Coming', 60),
(3, 2, 'Allegro - Najwiekszy Wybor', 15),
(4, 2, 'Smart Week Promo', 20),
(5, 3, 'Nike – Just Do It', 30),
(6, 3, 'Nike Air Max Campaign', 45),
(7, 4, 'Spotify Premium – No Ads', 30),
(8, 4, 'Spotify Wrapped', 60),
(9, 5, 'Samsung Galaxy Launch', 30),
(10, 5, 'Samsung Smart Life', 45),
(11, 6, 'McDonald''s New Menu', 30),
(12, 6, 'McDelivery Anytime', 20),
(13, 7, 'Red Bull Gives You Wings', 30),
(14, 7, 'Red Bull Extreme Sports', 45),
(15, 8, 'Winiary - Dekoracyjny do salatek', 15),
(16, 8, 'Pomysl na... Szybki obiad', 30),
(17, 8, 'Winiary - Wspolne sniadanie wielkanocne', 45),
(18, 9, 'Perla - Chmielowa swiezosc', 20),
(19, 9, 'Perla Export - Smak Lubelszczyzny', 30),
(20, 9, 'Perla - Idealna na grilla', 15);




INSERT INTO Users (UserID, Username, Email, DateOfBirth, RegistrationDate, CountryID) VALUES
(1, 'KingJames', 'lebron.business@gmail.com', '1984-12-30', '2023-01-01', 3),
(2, 'KingOfNewYork', 'melo.legend@yahoo.com', '1984-05-29', '2023-02-10', 3),
(3, 'AmonRa', 'stbrown.det@gmail.com', '1999-10-24', '2023-03-05', 3),
(4, 'HollywoodBrown', 'primetime5@outlook.com', '1997-06-04', '2023-03-15', 3),
(5, 'SlimReaper', 'kd.easymoney@gmail.com', '1988-09-29', '2023-04-20', 3),
(6, 'GreekFreak', 'giannis.anteto@gmail.com', '1994-12-06', '2023-05-12', 8),
(7, 'AntMan', 'a.edwards.fan@gmail.com', '2009-08-05', '2023-06-20', 3),
(8, 'TheProcess', 'embiid.trust@outlook.com', '2010-03-16', '2023-07-01', 3),
(9, 'SpidaMitchell', 'donovan.fan@yahoo.com', '2011-09-07', '2023-08-15', 3),
(10, 'MattyIce', 'ice.ryan.future@gmail.com', '2012-05-17', '2023-11-01', 3),
(11, 'TokyoVibes', 'tokyo.vibes@gmail.com', '1996-04-12', '2023-12-01', 10),
(12, 'BerlinBeats', 'berlin.beats@outlook.com', '1992-09-03', '2023-12-05', 2),
(13, 'LatinoFlow', 'latin.flow@yahoo.com', '1998-01-27', '2023-12-10', 11),
(14, 'SoundExplorer', 'sound.explorer@gmail.com', '1987-07-18', '2023-12-15', 4),
(15, 'MusicAddict', 'music.addict@outlook.com', '2001-11-09', '2023-12-20', 13),
(16, 'NightListener', 'night.listener@gmail.com', '1995-02-22', '2023-12-22', 8),
(17, 'PodcastFan', 'podcast.fan@yahoo.com', '1983-06-30', '2023-12-24', 1),
(18, 'VinylLover', 'vinyl.lover@gmail.com', '1979-03-14', '2023-12-26', 15),
(19, 'StreamKing', 'stream.king@outlook.com', '2004-08-01', '2023-12-28', 3),
(20, 'AudioNerd', 'audio.nerd@gmail.com', '1990-12-19', '2023-12-30', 16),
(21, 'TechEnthusiast', 'j.doe.tech@gmail.com', '1995-05-15', '2024-01-05', 3),
(22, 'PolskiFan', 'krzysztof.muzyka@wp.pl', '1988-11-20', '2024-01-10', 1),
(23, 'BerlinRavers', 'hans.berlin@web.de', '2000-02-28', '2024-01-12', 2),
(24, 'IbizaVibes', 'carlos.suarez@yahoo.es', '1993-07-04', '2024-01-15', 5),
(25, 'SoccerMom', 'martha.jones@outlook.com', '1982-03-12', '2024-01-18', 3);


DISABLE TRIGGER TR_UserSubscriptions_InsertWithValidation ON UserSubscriptions;
DISABLE TRIGGER TR_UserSubscriptions_SetEndDate ON UserSubscriptions;
INSERT INTO UserSubscriptions (UserSubscriptionID, UserID, SubscriptionTypeID, StartDate, EndDate, IsActive) VALUES 
(1, 1, 1, '2023-01-01', '2023-02-01', 0),
(2, 1, 1, '2024-01-01', '2024-02-01', 0),
(3, 1, 4, '2025-01-01', '2026-01-01', 1),
(4, 2, 2, '2023-05-15', '2023-08-15', 0),
(5, 2, 2, '2025-02-01', '2025-05-01', 1),
(6, 3, 3, '2024-03-01', '2024-09-01', 0),
(7, 4, 1, '2023-01-15', '2023-02-15', 0),
(8, 4, 2, '2025-04-01', '2025-07-01', 1),
(9, 5, 4, '2024-01-01', '2025-01-01', 0),
(10, 5, 4, '2025-01-01', '2026-01-01', 1),
(11, 6, 4, '2024-01-01', '2025-01-01', 0),
(12, 6, 4, '2025-01-01', '2026-01-01', 1),
(13, 7, 1, '2023-06-01', '2023-07-01', 0),
(14, 7, 1, '2025-06-01', '2025-07-01', 1),
(15, 8, 2, '2023-01-01', '2023-04-01', 0),
(16, 9, 3, '2023-08-01', '2024-02-01', 0),
(17, 10, 1, '2023-11-01', '2023-12-01', 0),
(18, 10, 1, '2025-09-01', '2025-10-01', 1),
(19, 11, 4, '2023-12-01', '2024-12-01', 0),
(20, 11, 4, '2025-01-01', '2026-01-01', 1),
(21, 12, 4, '2024-01-01', '2025-01-01', 0),
(22, 12, 4, '2025-01-01', '2026-01-01', 1),
(23, 13, 1, '2023-12-15', '2024-01-15', 0),
(24, 14, 3, '2023-12-15', '2024-06-15', 0),
(25, 14, 3, '2025-01-01', '2025-07-01', 1),
(26, 15, 2, '2023-12-20', '2024-03-20', 0),
(27, 15, 2, '2025-01-01', '2025-04-01', 1),
(28, 16, 2, '2023-12-22', '2024-03-22', 0),
(29, 16, 2, '2025-01-01', '2025-04-01', 1),
(30, 17, 1, '2023-12-24', '2024-01-24', 0),
(31, 17, 1, '2025-01-01', '2025-02-01', 1),
(32, 18, 3, '2023-12-26', '2024-06-26', 0),
(33, 18, 3, '2025-01-01', '2025-07-01', 1),
(34, 19, 1, '2023-12-28', '2024-01-28', 0),
(35, 19, 1, '2025-01-01', '2025-02-01', 1),
(36, 20, 1, '2023-12-30', '2024-01-30', 0),
(37, 20, 1, '2025-01-01', '2025-02-01', 1),
(38, 21, 1, '2024-01-05', '2024-02-05', 0),
(39, 21, 1, '2025-01-01', '2025-02-01', 1),
(40, 22, 2, '2024-01-10', '2024-04-10', 0),
(41, 22, 2, '2025-01-01', '2025-04-01', 1),
(42, 23, 2, '2024-01-12', '2024-04-12', 0),
(43, 23, 2, '2025-01-01', '2025-04-01', 1),
(44, 24, 4, '2024-01-15', '2025-01-15', 0),
(45, 24, 4, '2025-01-01', '2026-01-01', 1),
(46, 25, 2, '2024-01-18', '2024-04-18', 0),
(47, 25, 4, '2025-01-01', '2026-01-01', 1),
(48, 1, 1, '2022-01-01', '2022-02-01', 0),
(49, 5, 2, '2022-05-01', '2022-08-01', 0),
(50, 11, 3, '2022-10-01', '2023-04-01', 0);
ENABLE TRIGGER TR_UserSubscriptions_InsertWithValidation ON UserSubscriptions;
ENABLE TRIGGER TR_UserSubscriptions_SetEndDate ON UserSubscriptions;


INSERT INTO FollowsArtists (UserID, ArtistID, FollowDate) VALUES
(1,3,'2023-01-15'),(1,5,'2023-02-10'),(1,6,'2023-03-05'),
(2,1,'2023-02-20'),(2,2,'2023-03-15'),(2,13,'2023-04-10'),
(3,1,'2023-03-10'),(3,2,'2023-03-12'),(3,13,'2023-04-05'),(3,14,'2023-04-20'),
(4,11,'2023-04-01'),(4,12,'2023-04-15'),(4,13,'2023-05-10'),
(5,1,'2023-05-01'),(5,2,'2023-05-15'),(5,13,'2023-06-05'),
(6,3,'2023-06-01'),(6,5,'2023-06-15'),(6,8,'2023-07-10'),
(7,13,'2023-07-01'),(7,14,'2023-07-15'),(7,15,'2023-08-05'),
(8,11,'2023-07-10'),(8,12,'2023-08-01'),(8,7,'2023-08-20'),
(9,3,'2023-08-20'),(9,4,'2023-09-10'),(9,6,'2023-10-05'),
(10,13,'2023-11-05'),(10,14,'2023-11-20'),(10,15,'2023-12-01'),
(11,9,'2023-12-05'),(11,10,'2023-12-10'),(11,4,'2023-12-15'),
(12,3,'2023-12-10'),(12,13,'2023-12-15'),(12,5,'2023-12-20'),
(13,11,'2023-12-15'),(13,12,'2023-12-20'),(13,7,'2023-12-25'),
(14,5,'2023-12-20'),(14,3,'2023-12-24'),(14,18,'2023-12-28'),
(15,4,'2023-12-25'),(15,6,'2023-12-28'),(15,17,'2024-01-02'),
(16,3,'2023-12-26'),(16,5,'2023-12-30'),(16,18,'2024-01-05'),
(17,1,'2023-12-28'),(17,2,'2024-01-02'),
(18,5,'2023-12-30'),(18,3,'2024-01-05'),(18,17,'2024-01-10'),
(19,13,'2024-01-01'),(19,14,'2024-01-05'),(19,15,'2024-01-10'),(19,7,'2024-01-12'),
(20,5,'2024-01-02'),(20,3,'2024-01-08'),(20,9,'2024-01-12'),
(21,13,'2024-01-06'),(21,14,'2024-01-10'),
(22,4,'2024-01-11'),(22,5,'2024-01-15'),
(23,3,'2024-01-14'),(23,13,'2024-01-18'),(23,15,'2024-01-20'),
(24,11,'2024-01-17'),(24,12,'2024-01-20'),(24,8,'2024-01-22'),
(25,6,'2024-01-20'),(25,17,'2024-01-23'),(25,4,'2024-01-25');


INSERT INTO FollowsPodcasts (UserID, PodcastID, FollowDate) VALUES
(1,3,'2023-01-10'),(1,6,'2023-01-15'),
(2,3,'2023-02-15'),(2,7,'2023-03-01'),
(3,3,'2023-03-15'),(3,10,'2023-04-01'),
(4,2,'2023-04-05'),(4,4,'2023-04-12'),
(5,2,'2023-05-05'),(5,5,'2023-05-20'),
(6,1,'2023-06-05'),(6,10,'2023-06-20'),
(7,11,'2023-07-05'),(7,3,'2023-07-12'),(7,7,'2023-07-20'),
(8,3,'2023-07-15'),(8,7,'2023-08-05'),
(9,7,'2023-08-25'),(9,10,'2023-09-15'),
(10,10,'2023-11-10'),(10,3,'2023-11-25'),
(11,2,'2023-12-08'),(11,9,'2023-12-12'),
(12,2,'2023-12-12'),(12,4,'2023-12-18'),
(13,3,'2023-12-18'),(13,10,'2023-12-22'),
(14,2,'2023-12-22'),(14,5,'2023-12-26'),
(15,10,'2023-12-27'),(15,7,'2024-01-03'),
(16,4,'2023-12-28'),(16,2,'2024-01-04'),
(17,1,'2023-12-26'),(17,8,'2023-12-29'),(17,9,'2024-01-03'),
(18,7,'2024-01-02'),(18,3,'2024-01-07'),
(19,3,'2024-01-03'),(19,10,'2024-01-08'),
(20,9,'2024-01-05'),(20,5,'2024-01-10'),(20,2,'2024-01-14'),
(21,2,'2024-01-07'),(21,4,'2024-01-12'),(21,5,'2024-01-15'),
(22,1,'2024-01-12'),(22,8,'2024-01-16'),(22,9,'2024-01-19'),
(23,4,'2024-01-16'),(23,2,'2024-01-21'),
(24,3,'2024-01-19'),(24,10,'2024-01-24'),
(25,5,'2024-01-22'),(25,7,'2024-01-26');


INSERT INTO SongLikes (UserID, SongID, LikeDate) VALUES
(1,16,'2023-01-20'),(1,17,'2023-01-20'),(1,18,'2023-01-20'),(1,29,'2023-02-01'),(1,30,'2023-02-01'),(1,33,'2023-02-05'),(1,37,'2023-02-10'),(1,38,'2023-02-15'),(1,40,'2023-02-20'),
(2,1,'2023-03-01'),(2,2,'2023-03-01'),(2,3,'2023-03-01'),(2,7,'2023-03-10'),(2,8,'2023-03-10'),(2,12,'2023-03-15'),(2,79,'2024-09-14'),(2,80,'2023-12-25'),(2,81,'2023-12-25'),
(3,1,'2023-04-17'),(3,2,'2023-04-17'),(3,3,'2023-04-17'),(3,4,'2023-04-17'),(3,5,'2023-04-17'),(3,6,'2023-03-28'),(3,79,'2024-09-14'),(3,83,'2023-12-26'),(3,100,'2023-08-15'),(3,113,'2023-11-25'),
(4,64,'2023-03-30'),(4,65,'2023-03-30'),(4,66,'2023-03-30'),(4,68,'2023-05-10'),(4,69,'2023-05-10'),(4,70,'2023-11-01'),(4,71,'2023-07-15'),(4,72,'2023-07-15'),(4,78,'2023-12-25'),
(5,1,'2023-05-05'),(5,7,'2023-05-05'),(5,12,'2023-06-25'),(5,79,'2024-09-14'),(5,80,'2023-12-28'),(5,81,'2023-12-28'),(5,90,'2025-03-15'),(5,92,'2025-03-15'),
(6,16,'2023-01-25'),(6,21,'2023-10-10'),(6,22,'2023-05-15'),(6,29,'2023-01-20'),(6,33,'2023-11-20'),(6,54,'2023-06-05'),(6,55,'2023-06-05'),(6,57,'2023-06-20'),
(7,79,'2024-09-14'),(7,81,'2023-12-26'),(7,85,'2023-05-15'),(7,90,'2025-03-15'),(7,95,'2023-05-10'),(7,100,'2023-08-15'),(7,104,'2023-07-10'),(7,107,'2023-07-10'),(7,113,'2023-11-25'),
(8,64,'2023-03-05'),(8,68,'2023-05-10'),(8,69,'2023-05-10'),(8,70,'2023-11-05'),(8,74,'2023-12-22'),(8,47,'2023-08-30'),(8,48,'2023-08-30'),(8,50,'2023-07-05'),
(9,16,'2023-01-25'),(9,21,'2023-10-15'),(9,23,'2023-08-30'),(9,27,'2023-03-01'),(9,28,'2023-03-01'),(9,38,'2023-11-20'),(9,39,'2023-11-20'),(9,46,'2023-07-15'),
(10,79,'2024-09-14'),(10,81,'2023-12-26'),(10,100,'2023-08-15'),(10,101,'2023-08-15'),(10,107,'2023-07-10'),(10,108,'2023-07-10'),(10,113,'2023-11-25'),(10,116,'2023-05-01'),
(11,58,'2023-12-05'),(11,59,'2023-12-05'),(11,60,'2023-12-05'),(11,61,'2023-12-10'),(11,62,'2023-12-10'),(11,63,'2023-12-10'),(11,27,'2023-12-15'),(11,28,'2023-12-15'),
(12,16,'2023-01-25'),(12,20,'2023-01-25'),(12,21,'2023-10-15'),(12,29,'2023-01-20'),(12,33,'2023-11-20'),(12,79,'2024-09-14'),(12,81,'2023-12-26'),(12,85,'2023-05-15'),
(13,64,'2023-03-05'),(13,68,'2023-05-10'),(13,69,'2023-05-10'),(13,70,'2023-11-05'),(13,71,'2023-07-20'),(13,74,'2023-12-22'),(13,47,'2023-08-30'),(13,50,'2023-07-05'),
(14,29,'2023-01-20'),(14,30,'2023-01-20'),(14,33,'2023-11-20'),(14,37,'2023-12-10'),(14,16,'2023-01-25'),(14,21,'2023-10-15'),(14,121,'2023-12-20'),(14,122,'2025-05-10'),
(15,23,'2023-08-30'),(15,27,'2023-03-01'),(15,38,'2023-11-20'),(15,39,'2023-11-20'),(15,42,'2023-03-25'),(15,46,'2023-07-15'),(15,118,'2023-08-20'),(15,120,'2023-08-20'),
(16,16,'2023-01-25'),(16,21,'2023-10-15'),(16,29,'2023-01-20'),(16,33,'2023-11-20'),(16,37,'2023-12-10'),(16,121,'2023-12-20'),(16,122,'2025-05-10'),(16,124,'2025-05-10'),
(17,1,'2023-04-20'),(17,7,'2023-03-15'),(17,12,'2023-06-25'),(17,29,'2023-01-20'),(17,33,'2023-11-20'),(17,64,'2023-03-05'),(17,68,'2023-05-10'),(17,79,'2024-09-14'),
(18,29,'2023-01-20'),(18,30,'2023-01-20'),(18,33,'2023-11-20'),(18,16,'2023-01-25'),(18,21,'2023-10-15'),(18,118,'2023-08-20'),(18,119,'2023-08-20'),(18,121,'2023-12-20'),
(19,79,'2024-09-14'),(19,81,'2023-12-26'),(19,83,'2023-12-26'),(19,100,'2023-08-15'),(19,101,'2023-08-15'),(19,107,'2023-07-10'),(19,113,'2023-11-25'),(19,47,'2023-08-30'),
(20,29,'2023-01-20'),(20,33,'2023-11-20'),(20,16,'2023-01-25'),(20,58,'2023-12-10'),(20,61,'2023-12-15'),(20,121,'2023-12-20'),(20,122,'2025-05-10'),(20,53,'2023-10-20'),
(21,79,'2024-09-14'),(21,81,'2023-12-26'),(21,85,'2023-05-15'),(21,95,'2023-05-10'),(21,100,'2023-08-15'),(21,107,'2023-07-10'),(21,113,'2023-11-25'),(21,53,'2023-10-20'),
(22,23,'2023-08-30'),(22,27,'2023-03-01'),(22,28,'2023-03-01'),(22,29,'2023-01-20'),(22,33,'2023-11-20'),(22,1,'2023-04-20'),(22,7,'2023-03-15'),(22,12,'2023-06-25'),
(23,16,'2023-01-25'),(23,21,'2023-10-15'),(23,79,'2024-09-14'),(23,81,'2023-12-26'),(23,100,'2023-08-15'),(23,107,'2023-07-10'),(23,113,'2023-11-25'),(23,95,'2023-05-10'),
(24,64,'2023-03-05'),(24,68,'2023-05-10'),(24,69,'2023-05-10'),(24,70,'2023-11-05'),(24,74,'2023-12-22'),(24,54,'2023-06-05'),(24,56,'2023-06-05'),(24,57,'2023-06-20'),
(25,38,'2023-11-20'),(25,39,'2023-11-20'),(25,43,'2023-03-25'),(25,46,'2023-07-15'),(25,23,'2023-08-30'),(25,27,'2023-03-01'),(25,118,'2023-08-20'),(25,120,'2023-08-20');


INSERT INTO EpisodeLikes (UserID, EpisodeID, LikeDate) VALUES
(1,11,'2023-12-05'),(1,12,'2023-12-06'),(1,22,'2023-09-25'),(1,23,'2023-10-05'),
(2,11,'2023-12-05'),(2,13,'2023-12-15'),(2,25,'2023-09-25'),(2,26,'2023-10-10'),
(3,11,'2023-12-05'),(3,15,'2023-12-25'),(3,34,'2024-01-15'),(3,36,'2024-01-30'),
(4,6,'2023-11-05'),(4,7,'2023-11-15'),(4,16,'2023-09-20'),(4,17,'2023-10-05'),
(5,6,'2023-11-05'),(5,9,'2023-11-25'),(5,19,'2023-10-05'),(5,21,'2023-11-05'),
(6,1,'2023-10-05'),(6,2,'2023-10-10'),(6,34,'2024-01-15'),(6,35,'2024-01-20'),
(7,37,'2024-02-05'),(7,38,'2024-02-10'),(7,11,'2023-12-05'),(7,25,'2023-09-25'),
(8,11,'2023-12-05'),(8,14,'2023-12-20'),(8,25,'2023-09-25'),(8,27,'2023-10-25'),
(9,25,'2023-09-25'),(9,26,'2023-10-10'),(9,34,'2024-01-15'),(9,35,'2024-01-20'),
(10,34,'2024-01-15'),(10,36,'2024-01-30'),(10,11,'2023-12-05'),(10,13,'2023-12-15'),
(11,6,'2023-11-05'),(11,8,'2023-11-20'),(11,31,'2023-09-20'),(11,32,'2023-10-05'),
(12,6,'2023-11-05'),(12,7,'2023-11-15'),(12,16,'2023-09-20'),(12,18,'2023-10-20'),
(13,11,'2023-12-05'),(13,15,'2023-12-25'),(13,34,'2024-01-15'),(13,36,'2024-01-30'),
(14,6,'2023-11-05'),(14,10,'2023-11-30'),(14,19,'2023-10-05'),(14,20,'2023-10-20'),
(15,34,'2024-01-15'),(15,35,'2024-01-20'),(15,25,'2023-09-25'),(15,27,'2023-10-25'),
(16,16,'2023-09-20'),(16,17,'2023-10-05'),(16,6,'2023-11-05'),(16,7,'2023-11-15'),
(17,1,'2023-10-05'),(17,3,'2023-10-20'),(17,28,'2023-09-30'),(17,31,'2023-09-20'),
(18,25,'2023-09-25'),(18,26,'2023-10-10'),(18,11,'2023-12-05'),(18,12,'2023-12-10'),
(19,11,'2023-12-05'),(19,15,'2023-12-25'),(19,34,'2024-01-15'),(19,35,'2024-01-20'),
(20,31,'2023-09-20'),(20,33,'2023-10-20'),(20,19,'2023-10-05'),(20,6,'2023-11-05'),
(21,6,'2023-11-05'),(21,7,'2023-11-15'),(21,16,'2023-09-20'),(21,19,'2023-10-05'),
(22,1,'2023-10-05'),(22,4,'2023-10-25'),(22,28,'2023-09-30'),(22,31,'2023-09-20'),
(23,16,'2023-09-20'),(23,18,'2023-10-20'),(23,6,'2023-11-05'),(23,9,'2023-11-25'),
(24,11,'2023-12-05'),(24,14,'2023-12-20'),(24,34,'2024-01-15'),(24,36,'2024-01-30'),
(25,19,'2023-10-05'),(25,21,'2023-11-05'),(25,25,'2023-09-25'),(25,26,'2023-10-10');



USE SPOTIFY;
GO


INSERT INTO PlaybackHistory (UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID) VALUES
(7, '2024-02-01 14:00:00', 180, 1, 'SONG', 47),
(7, '2024-02-01 14:03:30', 221, 1, 'SONG', 48),
(7, '2024-02-01 14:07:00', 207, 1, 'SONG', 49),
(13, '2024-02-01 15:00:00', 172, 1, 'SONG', 64),
(13, '2024-02-01 15:03:00', 295, 1, 'SONG', 65),
(13, '2024-02-01 15:08:00', 163, 1, 'SONG', 66),
(11, '2024-02-02 10:00:00', 238, 3, 'SONG', 61),
(11, '2024-02-02 10:04:00', 256, 3, 'SONG', 62),
(11, '2024-02-02 10:08:00', 242, 3, 'SONG', 63),
(19, '2024-02-02 18:00:00', 148, 1, 'SONG', 79),
(19, '2024-02-02 18:03:00', 218, 1, 'SONG', 81),
(19, '2024-02-02 18:07:00', 193, 1, 'SONG', 83),
(21, '2024-02-03 12:00:00', 148, 3, 'SONG', 100),
(21, '2024-02-03 12:03:00', 152, 3, 'SONG', 101),
(21, '2024-02-03 12:06:00', 148, 3, 'SONG', 102),
(23, '2024-02-03 20:00:00', 191, 1, 'SONG', 16),
(23, '2024-02-03 20:04:00', 186, 1, 'SONG', 21),
(23, '2024-02-03 20:08:00', 148, 1, 'SONG', 79),
(24, '2024-02-04 11:00:00', 172, 1, 'SONG', 64),
(24, '2024-02-04 11:03:00', 178, 1, 'SONG', 68),
(24, '2024-02-04 11:06:00', 244, 1, 'SONG', 69),
(25, '2024-02-04 15:00:00', 200, 1, 'SONG', 38),
(25, '2024-02-04 15:04:00', 233, 1, 'SONG', 39),
(25, '2024-02-04 15:08:00', 153, 1, 'SONG', 43),
(3, '2024-02-05 09:00:00', 254, 4, 'SONG', 1),
(3, '2024-02-05 09:05:00', 119, 4, 'SONG', 80),
(3, '2024-02-05 09:07:00', 193, 4, 'SONG', 83),
(5, '2024-02-05 14:00:00', 254, 1, 'SONG', 1),
(5, '2024-02-05 14:05:00', 225, 1, 'SONG', 7),
(5, '2024-02-05 14:09:00', 148, 1, 'SONG', 79),
(8, '2024-02-06 08:00:00', 172, 1, 'SONG', 64),
(8, '2024-02-06 08:03:00', 178, 1, 'SONG', 68),
(8, '2024-02-06 08:07:00', 192, 1, 'SONG', 50),
(10, '2024-02-06 16:00:00', 148, 1, 'SONG', 79),
(10, '2024-02-06 16:03:00', 218, 1, 'SONG', 81),
(10, '2024-02-06 16:07:00', 174, 1, 'SONG', 100),
(15, '2024-02-07 10:04:00', 233, 3, 'SONG', 39),
(15, '2024-02-07 10:08:00', 165, 3, 'SONG', 118),
(17, '2024-02-07 15:00:00', 254, 1, 'SONG', 1),
(17, '2024-02-07 15:05:00', 172, 1, 'SONG', 64),
(17, '2024-02-07 15:08:00', 148, 1, 'SONG', 79),
(1, '2024-02-08 09:00:00', 191, 1, 'SONG', 16),
(1, '2024-02-08 09:04:00', 179, 1, 'SONG', 18),
(1, '2024-02-08 09:07:00', 198, 1, 'SONG', 42),
(4, '2024-02-08 14:00:00', 172, 1, 'SONG', 64),
(4, '2024-02-08 14:03:00', 295, 1, 'SONG', 65),
(4, '2024-02-08 14:08:00', 254, 1, 'SONG', 71),
(9, '2024-02-09 11:00:00', 191, 1, 'SONG', 16),
(9, '2024-02-09 11:04:00', 186, 1, 'SONG', 21),
(4, '2024-03-01 10:00:00', 190, 1, 'SONG', 23),
(4, '2024-03-01 10:04:00', 199, 1, 'SONG', 24),
(4, '2024-03-01 10:08:00', 179, 1, 'SONG', 27),
(6, '2024-03-01 11:00:00', 191, 1, 'SONG', 16),
(6, '2024-03-01 11:04:00', 186, 1, 'SONG', 21),
(6, '2024-03-01 11:08:00', 253, 1, 'SONG', 54),
(8, '2024-03-02 12:00:00', 172, 3, 'SONG', 64),
(8, '2024-03-02 12:03:00', 178, 3, 'SONG', 68),
(8, '2024-03-02 12:07:00', 180, 3, 'SONG', 47),
(9, '2024-03-02 14:00:00', 191, 1, 'SONG', 16),
(9, '2024-03-02 14:04:00', 200, 1, 'SONG', 38),
(9, '2024-03-02 14:08:00', 141, 1, 'SONG', 46),
(10, '2024-03-03 16:00:00', 148, 1, 'SONG', 79),
(10, '2024-03-03 16:03:00', 174, 1, 'SONG', 100),
(10, '2024-03-03 16:07:00', 145, 1, 'SONG', 113),
(12, '2024-03-03 18:00:00', 191, 3, 'SONG', 16),
(12, '2024-03-03 18:04:00', 148, 3, 'SONG', 79),
(12, '2024-03-03 18:07:00', 192, 3, 'SONG', 85),
(14, '2024-03-04 09:00:00', 233, 1, 'SONG', 29),
(14, '2024-03-04 09:04:00', 285, 1, 'SONG', 37),
(15, '2024-03-04 11:00:00', 179, 1, 'SONG', 27),
(15, '2024-03-04 11:07:00', 165, 1, 'SONG', 118),
(17, '2024-03-05 13:00:00', 254, 4, 'SONG', 1),
(18, '2024-03-05 15:00:00', 294, 3, 'SONG', 30),
(18, '2024-03-05 15:05:00', 178, 3, 'SONG', 119),
(19, '2024-03-06 17:00:00', 148, 1, 'SONG', 79),
(19, '2024-03-06 17:03:00', 152, 1, 'SONG', 101),
(20, '2024-03-06 19:00:00', 231, 3, 'SONG', 58),
(20, '2024-03-06 19:04:00', 122, 3, 'SONG', 53),
(21, '2024-03-07 08:00:00', 148, 1, 'SONG', 79),
(21, '2024-03-07 08:03:00', 154, 1, 'SONG', 95),
(22, '2024-03-07 10:00:00', 190, 3, 'SONG', 23),
(22, '2024-03-07 10:04:00', 225, 3, 'SONG', 7),
(23, '2024-03-08 12:00:00', 191, 1, 'SONG', 16),
(23, '2024-03-08 12:04:00', 148, 1, 'SONG', 100),
(24, '2024-03-08 14:00:00', 172, 3, 'SONG', 64),
(24, '2024-03-08 14:03:00', 253, 3, 'SONG', 54),
(25, '2024-03-09 11:03:00', 190, 1, 'SONG', 23),
(1, '2024-03-09 14:00:00', 164, 1, 'SONG', 19),
(2, '2024-03-10 10:00:00', 148, 3, 'SONG', 79),
(3, '2024-03-10 12:00:00', 212, 1, 'SONG', 6),
(4, '2024-03-11 15:00:00', 244, 4, 'SONG', 69),
(5, '2024-03-11 17:00:00', 180, 1, 'SONG', 90),
(6, '2024-03-12 09:00:00', 223, 1, 'SONG', 57),
(7, '2024-03-12 11:00:00', 187, 1, 'SONG', 96),
(8, '2024-03-13 13:00:00', 180, 1, 'SONG', 47),
(9, '2024-03-13 15:00:00', 179, 1, 'SONG', 27),
(7, '2024-04-01 10:00:00', 192, 1, 'SONG', 50),
(7, '2024-04-01 10:03:30', 210, 1, 'SONG', 51),
(7, '2024-04-01 10:07:00', 191, 1, 'SONG', 52),
(8, '2024-04-01 11:00:00', 253, 3, 'SONG', 54),
(8, '2024-04-01 11:04:00', 211, 3, 'SONG', 55),
(8, '2024-04-01 11:08:00', 223, 3, 'SONG', 57),
(9, '2024-04-02 12:00:00', 191, 1, 'SONG', 16),
(9, '2024-04-02 12:03:00', 186, 1, 'SONG', 21),
(9, '2024-04-02 12:06:00', 141, 1, 'SONG', 46),
(11, '2024-04-02 14:00:00', 231, 3, 'SONG', 58),
(11, '2024-04-02 14:04:00', 338, 3, 'SONG', 59),
(11, '2024-04-02 14:09:00', 347, 3, 'SONG', 60),
(13, '2024-04-03 16:00:00', 172, 1, 'SONG', 64),
(13, '2024-04-03 16:03:00', 295, 1, 'SONG', 65),
(13, '2024-04-03 16:08:00', 244, 1, 'SONG', 69),
(15, '2024-04-03 18:04:00', 233, 1, 'SONG', 39),
(15, '2024-04-03 18:08:00', 141, 1, 'SONG', 46),
(19, '2024-04-04 09:00:00', 148, 1, 'SONG', 79),
(19, '2024-04-04 09:03:00', 218, 1, 'SONG', 81),
(19, '2024-04-04 09:06:00', 193, 1, 'SONG', 83),
(21, '2024-04-04 11:00:00', 148, 3, 'SONG', 100),
(21, '2024-04-04 11:03:00', 160, 3, 'SONG', 103),
(21, '2024-04-04 11:06:00', 175, 3, 'SONG', 91),
(23, '2024-04-05 13:00:00', 191, 1, 'SONG', 16),
(23, '2024-04-05 13:03:00', 148, 1, 'SONG', 79),
(23, '2024-04-05 13:06:00', 158, 1, 'SONG', 111),
(25, '2024-04-05 15:00:00', 233, 1, 'SONG', 39),
(25, '2024-04-05 15:04:00', 205, 1, 'SONG', 40),
(25, '2024-04-05 15:08:00', 170, 1, 'SONG', 44),
(1, '2024-04-06 08:00:00', 191, 1, 'SONG', 16),
(1, '2024-04-06 08:03:00', 168, 1, 'SONG', 17),
(2, '2024-04-06 09:00:00', 254, 3, 'SONG', 1),
(2, '2024-04-06 09:05:00', 148, 3, 'SONG', 79),
(3, '2024-04-07 10:00:00', 254, 1, 'SONG', 1),
(3, '2024-04-07 10:04:00', 212, 1, 'SONG', 6),
(4, '2024-04-07 11:00:00', 172, 1, 'SONG', 64),
(4, '2024-04-07 11:03:00', 245, 1, 'SONG', 67),
(5, '2024-04-08 12:00:00', 254, 1, 'SONG', 1),
(5, '2024-04-08 12:05:00', 148, 1, 'SONG', 79),
(6, '2024-04-08 13:00:00', 186, 1, 'SONG', 21),
(6, '2024-04-08 13:03:00', 223, 1, 'SONG', 57),
(7, '2024-04-09 14:00:00', 174, 1, 'SONG', 100),
(7, '2024-04-09 14:03:00', 152, 1, 'SONG', 101),
(8, '2024-04-09 15:00:00', 180, 1, 'SONG', 47),
(8, '2024-04-09 15:03:00', 192, 1, 'SONG', 50),
(10, '2024-04-10 16:00:00', 148, 1, 'SONG', 79),
(10, '2024-04-10 16:03:00', 150, 1, 'SONG', 116),
(11, '2024-04-10 17:00:00', 231, 3, 'SONG', 58),
(11, '2024-04-10 17:04:00', 242, 3, 'SONG', 63),
(15, '2024-05-01 09:00:00', 200, 1, 'SONG', 38),
(15, '2024-05-01 09:03:30', 233, 1, 'SONG', 39),
(15, '2024-05-01 09:07:30', 141, 1, 'SONG', 46),
(14, '2024-05-01 10:00:00', 233, 1, 'SONG', 29),
(14, '2024-05-01 10:04:00', 233, 1, 'SONG', 39),
(14, '2024-05-01 10:08:00', 145, 1, 'SONG', 121),
(16, '2024-05-02 11:00:00', 191, 1, 'SONG', 16),
(16, '2024-05-02 11:03:30', 186, 1, 'SONG', 21),
(16, '2024-05-02 11:06:30', 162, 1, 'SONG', 122),
(18, '2024-05-02 14:00:00', 233, 3, 'SONG', 29),
(18, '2024-05-02 14:04:00', 294, 3, 'SONG', 30),
(18, '2024-05-02 14:09:00', 165, 3, 'SONG', 118),
(20, '2024-05-03 16:00:00', 191, 3, 'SONG', 16),
(20, '2024-05-03 16:03:30', 233, 3, 'SONG', 29),
(20, '2024-05-03 16:07:30', 162, 3, 'SONG', 122),
(25, '2024-05-03 18:00:00', 200, 1, 'SONG', 38),
(25, '2024-05-03 18:03:30', 233, 1, 'SONG', 39),
(25, '2024-05-03 18:07:30', 165, 1, 'SONG', 118),
(2, '2024-05-04 09:00:00', 254, 3, 'SONG', 1),
(2, '2024-05-04 09:04:30', 225, 3, 'SONG', 7),
(2, '2024-05-04 09:08:30', 148, 3, 'SONG', 79),
(3, '2024-05-04 11:00:00', 254, 1, 'SONG', 1),
(3, '2024-05-04 11:04:30', 148, 1, 'SONG', 79),
(3, '2024-05-04 11:07:00', 145, 1, 'SONG', 113),
(5, '2024-05-05 13:00:00', 254, 1, 'SONG', 1),
(5, '2024-05-05 13:04:30', 225, 1, 'SONG', 7),
(5, '2024-05-05 13:08:00', 148, 1, 'SONG', 79),
(11, '2024-05-05 15:00:00', 231, 3, 'SONG', 58),
(11, '2024-05-05 15:04:00', 338, 3, 'SONG', 59),
(11, '2024-05-05 15:10:00', 238, 3, 'SONG', 61),
(13, '2024-05-06 17:00:00', 172, 1, 'SONG', 64),
(13, '2024-05-06 17:03:00', 295, 1, 'SONG', 65),
(13, '2024-05-06 17:08:00', 180, 1, 'SONG', 47),
(17, '2024-05-06 19:00:00', 254, 1, 'SONG', 1),
(17, '2024-05-06 19:04:30', 172, 1, 'SONG', 64),
(17, '2024-05-06 19:07:30', 148, 1, 'SONG', 79),
(19, '2024-05-07 08:00:00', 148, 1, 'SONG', 79),
(19, '2024-05-07 08:02:30', 174, 1, 'SONG', 100),
(19, '2024-05-07 08:05:30', 145, 1, 'SONG', 113),
(21, '2024-05-07 10:00:00', 148, 3, 'SONG', 79),
(21, '2024-05-07 10:02:30', 192, 3, 'SONG', 85),
(21, '2024-05-07 10:06:00', 145, 3, 'SONG', 113),
(23, '2024-05-08 12:00:00', 191, 1, 'SONG', 16),
(23, '2024-05-08 12:03:00', 186, 1, 'SONG', 21),
(23, '2024-05-08 12:06:00', 148, 1, 'SONG', 100),
(24, '2024-05-08 14:00:00', 172, 1, 'SONG', 64),
(24, '2024-05-08 14:03:00', 178, 1, 'SONG', 68),
(24, '2024-05-08 14:06:00', 253, 1, 'SONG', 54),
(1, '2024-05-09 16:00:00', 191, 1, 'SONG', 16),
(1, '2024-05-09 16:03:30', 233, 1, 'SONG', 29),
(2, '2024-06-01 09:00:00', 225, 1, 'SONG', 7),
(2, '2024-06-01 09:04:00', 201, 1, 'SONG', 8),
(2, '2024-06-01 09:07:30', 223, 1, 'SONG', 12),
(3, '2024-06-01 11:00:00', 212, 4, 'SONG', 6),
(3, '2024-06-01 11:03:40', 148, 4, 'SONG', 79),
(3, '2024-06-01 11:06:10', 193, 4, 'SONG', 83),
(4, '2024-06-02 12:00:00', 245, 1, 'SONG', 67),
(4, '2024-06-02 12:04:30', 205, 1, 'SONG', 70),
(4, '2024-06-02 12:08:00', 254, 1, 'SONG', 71),
(5, '2024-06-02 15:00:00', 254, 3, 'SONG', 1),
(5, '2024-06-02 15:04:30', 119, 3, 'SONG', 80),
(5, '2024-06-02 15:06:40', 180, 3, 'SONG', 90),
(7, '2024-06-03 10:00:00', 148, 1, 'SONG', 79),
(7, '2024-06-03 10:02:30', 180, 1, 'SONG', 90),
(7, '2024-06-03 10:05:40', 154, 1, 'SONG', 95),
(8, '2024-06-03 13:00:00', 172, 3, 'SONG', 64),
(8, '2024-06-03 13:03:00', 178, 3, 'SONG', 68),
(8, '2024-06-03 13:06:10', 207, 3, 'SONG', 49),
(10, '2024-06-04 16:00:00', 218, 1, 'SONG', 81),
(10, '2024-06-04 16:03:50', 174, 1, 'SONG', 100),
(10, '2024-06-04 16:06:50', 195, 1, 'SONG', 107),
(11, '2024-06-04 18:00:00', 179, 3, 'SONG', 27),
(11, '2024-06-04 18:03:10', 190, 3, 'SONG', 28),
(11, '2024-06-04 18:06:20', 256, 3, 'SONG', 62),
(13, '2024-06-05 20:00:00', 244, 1, 'SONG', 69),
(13, '2024-06-05 20:04:10', 205, 1, 'SONG', 70),
(13, '2024-06-05 20:07:40', 192, 1, 'SONG', 50),
(17, '2024-06-05 22:00:00', 225, 1, 'SONG', 7),
(17, '2024-06-05 22:07:30', 172, 1, 'SONG', 64),
(19, '2024-06-06 09:00:00', 193, 1, 'SONG', 83),
(19, '2024-06-06 09:03:20', 152, 1, 'SONG', 101),
(19, '2024-06-06 09:06:00', 180, 1, 'SONG', 47),
(21, '2024-06-06 12:03:00', 145, 3, 'SONG', 113),
(21, '2024-06-06 12:05:30', 122, 3, 'SONG', 53),
(23, '2024-06-07 14:00:00', 218, 1, 'SONG', 81),
(23, '2024-06-07 14:03:50', 195, 1, 'SONG', 107),
(23, '2024-06-07 14:07:10', 154, 1, 'SONG', 95),
(24, '2024-06-07 16:00:00', 244, 1, 'SONG', 69),
(24, '2024-06-07 16:04:10', 285, 1, 'SONG', 74),
(24, '2024-06-07 16:09:00', 223, 1, 'SONG', 57),
(1, '2024-06-08 10:00:00', 233, 1, 'SONG', 39),
(1, '2024-06-08 10:04:00', 205, 1, 'SONG', 40),
(6, '2024-06-08 13:00:00', 223, 1, 'SONG', 57),
(6, '2024-06-08 13:04:00', 253, 1, 'SONG', 54),
(12, '2024-06-09 15:00:00', 148, 1, 'SONG', 79),
(12, '2024-06-09 15:02:30', 218, 1, 'SONG', 81),
(15, '2024-06-09 17:00:00', 198, 1, 'SONG', 42),
(15, '2024-06-09 17:03:30', 141, 1, 'SONG', 46),
(6, '2024-07-01 10:00:00', 253, 1, 'SONG', 54),
(6, '2024-07-01 10:05:00', 211, 1, 'SONG', 55),
(6, '2024-07-01 10:09:00', 194, 1, 'SONG', 56),
(7, '2024-07-01 14:00:00', 180, 4, 'SONG', 47),
(7, '2024-07-01 14:04:00', 122, 4, 'SONG', 53),
(7, '2024-07-01 14:07:00', 174, 4, 'SONG', 100),
(8, '2024-07-02 09:00:00', 172, 1, 'SONG', 64),
(8, '2024-07-02 09:03:00', 295, 1, 'SONG', 65),
(8, '2024-07-02 09:08:00', 180, 1, 'SONG', 47),
(9, '2024-07-02 12:00:00', 190, 1, 'SONG', 23),
(9, '2024-07-02 12:04:00', 179, 1, 'SONG', 27),
(9, '2024-07-02 12:08:00', 141, 1, 'SONG', 46),
(10, '2024-07-03 15:00:00', 148, 1, 'SONG', 79),
(10, '2024-07-03 15:03:00', 152, 1, 'SONG', 101),
(10, '2024-07-03 15:06:00', 138, 1, 'SONG', 117),
(13, '2024-07-03 18:00:00', 180, 1, 'SONG', 47),
(13, '2024-07-03 18:04:00', 192, 1, 'SONG', 50),
(13, '2024-07-03 18:08:00', 172, 1, 'SONG', 64),
(14, '2024-07-04 10:00:00', 145, 1, 'SONG', 121),
(14, '2024-07-04 10:03:00', 162, 1, 'SONG', 122),
(14, '2024-07-04 10:06:00', 158, 1, 'SONG', 123),
(15, '2024-07-04 14:00:00', 200, 1, 'SONG', 38),
(15, '2024-07-04 14:04:00', 198, 1, 'SONG', 42),
(15, '2024-07-04 14:08:00', 155, 1, 'SONG', 120),
(16, '2024-07-05 16:00:00', 145, 1, 'SONG', 121),
(16, '2024-07-05 16:03:00', 162, 1, 'SONG', 122),
(16, '2024-07-05 16:06:00', 170, 1, 'SONG', 124),
(18, '2024-07-05 18:00:00', 233, 3, 'SONG', 29),
(18, '2024-07-05 18:04:00', 178, 3, 'SONG', 119),
(18, '2024-07-05 18:07:00', 145, 3, 'SONG', 121),
(20, '2024-07-06 09:00:00', 191, 3, 'SONG', 16),
(20, '2024-07-06 09:04:00', 231, 3, 'SONG', 58),
(20, '2024-07-06 09:08:00', 122, 3, 'SONG', 53),
(21, '2024-07-06 12:00:00', 148, 3, 'SONG', 79),
(21, '2024-07-06 12:03:00', 154, 3, 'SONG', 95),
(21, '2024-07-06 12:06:00', 122, 3, 'SONG', 53),
(22, '2024-07-07 11:00:00', 190, 1, 'SONG', 23),
(22, '2024-07-07 11:04:00', 254, 1, 'SONG', 1),
(22, '2024-07-07 11:09:00', 225, 1, 'SONG', 7),
(23, '2024-07-07 14:00:00', 148, 1, 'SONG', 79),
(23, '2024-07-07 14:03:00', 174, 1, 'SONG', 100),
(23, '2024-07-07 14:06:00', 154, 1, 'SONG', 95),
(24, '2024-07-08 15:00:00', 253, 1, 'SONG', 54),
(24, '2024-07-08 15:04:00', 223, 1, 'SONG', 57),
(24, '2024-07-08 15:08:00', 172, 1, 'SONG', 64),
(25, '2024-07-08 17:04:00', 153, 1, 'SONG', 43),
(25, '2024-07-08 17:07:00', 155, 1, 'SONG', 120),
(1, '2024-07-09 08:00:00', 285, 1, 'SONG', 37),
(2, '2024-07-09 10:00:00', 148, 3, 'SONG', 79),
(11, '2024-08-01 10:00:00', 231, 3, 'SONG', 58),
(11, '2024-08-01 10:04:00', 242, 3, 'SONG', 63),
(11, '2024-08-01 10:08:00', 256, 3, 'SONG', 62),
(15, '2024-08-01 12:00:00', 165, 1, 'SONG', 118),
(15, '2024-08-01 12:03:00', 178, 1, 'SONG', 119),
(15, '2024-08-01 12:06:00', 155, 1, 'SONG', 120),
(25, '2024-08-02 14:00:00', 190, 1, 'SONG', 23),
(25, '2024-08-02 14:03:00', 153, 1, 'SONG', 43),
(25, '2024-08-02 14:06:00', 165, 1, 'SONG', 118),
(7, '2024-08-03 09:00:00', 174, 4, 'SONG', 100),
(7, '2024-08-03 09:03:00', 152, 4, 'SONG', 101),
(7, '2024-08-03 09:06:00', 148, 4, 'SONG', 102),
(10, '2024-08-03 11:00:00', 148, 1, 'SONG', 79),
(10, '2024-08-03 11:03:00', 160, 1, 'SONG', 103),
(10, '2024-08-03 11:06:00', 195, 1, 'SONG', 107),
(19, '2024-08-04 15:00:00', 152, 1, 'SONG', 101),
(19, '2024-08-04 15:03:00', 148, 1, 'SONG', 102),
(19, '2024-08-04 15:06:00', 193, 1, 'SONG', 83),
(21, '2024-08-04 17:00:00', 148, 3, 'SONG', 100),
(21, '2024-08-04 17:03:00', 154, 3, 'SONG', 95),
(21, '2024-08-04 17:06:00', 172, 3, 'SONG', 108),
(23, '2024-08-05 13:00:00', 148, 1, 'SONG', 79),
(23, '2024-08-05 13:03:00', 174, 1, 'SONG', 100),
(23, '2024-08-05 13:06:00', 154, 1, 'SONG', 95),
(1, '2024-08-05 18:00:00', 191, 1, 'SONG', 16),
(1, '2024-08-05 18:03:30', 233, 1, 'SONG', 29),
(2, '2024-08-06 09:00:00', 254, 3, 'SONG', 1),
(2, '2024-08-06 09:04:30', 225, 3, 'SONG', 7),
(3, '2024-08-06 11:00:00', 212, 1, 'SONG', 6),
(3, '2024-08-06 11:03:40', 148, 1, 'SONG', 79),
(4, '2024-08-07 15:00:00', 172, 1, 'SONG', 64),
(4, '2024-08-07 15:03:00', 295, 1, 'SONG', 65),
(5, '2024-08-07 17:00:00', 254, 1, 'SONG', 1),
(5, '2024-08-07 17:04:30', 225, 1, 'SONG', 7),
(6, '2024-08-08 08:00:00', 186, 1, 'SONG', 21),
(6, '2024-08-08 08:03:00', 253, 1, 'SONG', 54),
(8, '2024-08-08 10:00:00', 172, 3, 'SONG', 64),
(8, '2024-08-08 10:03:00', 192, 3, 'SONG', 50),
(9, '2024-08-09 14:00:00', 191, 1, 'SONG', 16),
(9, '2024-08-09 14:04:00', 179, 1, 'SONG', 27),
(12, '2024-08-09 16:00:00', 148, 1, 'SONG', 79),
(12, '2024-08-09 16:02:30', 191, 1, 'SONG', 16),
(13, '2024-08-10 18:00:00', 172, 1, 'SONG', 64),
(13, '2024-08-10 18:03:00', 244, 1, 'SONG', 69),
(14, '2024-08-11 11:00:00', 145, 1, 'SONG', 121),
(14, '2024-08-11 11:03:00', 162, 1, 'SONG', 122),
(16, '2024-08-11 13:00:00', 145, 1, 'SONG', 121),
(16, '2024-08-11 13:03:00', 162, 1, 'SONG', 122),
(17, '2024-08-12 15:00:00', 254, 4, 'SONG', 1),
(17, '2024-08-12 15:05:00', 172, 4, 'SONG', 64),
(1, '2024-09-01 10:00:00', 141, 1, 'SONG', 46),
(1, '2024-09-01 10:04:00', 285, 1, 'SONG', 37),
(2, '2024-09-02 11:00:00', 254, 3, 'SONG', 1),
(2, '2024-09-02 11:05:00', 223, 3, 'SONG', 12),
(3, '2024-09-03 12:00:00', 148, 1, 'SONG', 79),
(3, '2024-09-03 12:03:00', 153, 1, 'SONG', 88),
(4, '2024-09-04 13:00:00', 245, 1, 'SONG', 67),
(4, '2024-09-04 13:04:00', 254, 1, 'SONG', 71),
(5, '2024-09-05 14:00:00', 254, 3, 'SONG', 1),
(5, '2024-09-05 14:05:00', 218, 3, 'SONG', 81),
(6, '2024-09-06 15:00:00', 247, 1, 'SONG', 20),
(6, '2024-09-06 15:04:00', 223, 1, 'SONG', 57),
(7, '2024-09-07 16:00:00', 180, 4, 'SONG', 90),
(7, '2024-09-07 16:03:00', 174, 4, 'SONG', 100),
(8, '2024-09-08 17:00:00', 178, 1, 'SONG', 68),
(8, '2024-09-08 17:03:00', 180, 1, 'SONG', 47),
(9, '2024-09-09 18:00:00', 186, 1, 'SONG', 21),
(9, '2024-09-09 18:04:00', 179, 1, 'SONG', 27),
(10, '2024-09-10 19:00:00', 195, 1, 'SONG', 107),
(10, '2024-09-10 19:04:00', 150, 1, 'SONG', 116),
(11, '2024-09-11 20:00:00', 238, 3, 'SONG', 61),
(11, '2024-09-11 20:04:00', 179, 3, 'SONG', 27),
(12, '2024-09-12 21:00:00', 191, 1, 'SONG', 16),
(12, '2024-09-12 21:04:00', 148, 1, 'SONG', 79),
(13, '2024-09-13 10:00:00', 205, 1, 'SONG', 70),
(13, '2024-09-13 10:04:00', 180, 1, 'SONG', 47),
(14, '2024-09-14 11:04:00', 145, 1, 'SONG', 121),
(15, '2024-09-15 12:00:00', 179, 1, 'SONG', 27),
(15, '2024-09-15 12:03:00', 165, 1, 'SONG', 118),
(16, '2024-09-16 13:00:00', 186, 1, 'SONG', 21),
(16, '2024-09-16 13:03:00', 162, 1, 'SONG', 122),
(17, '2024-09-17 14:00:00', 225, 1, 'SONG', 7),
(17, '2024-09-17 14:04:00', 172, 1, 'SONG', 64),
(18, '2024-09-18 15:00:00', 285, 3, 'SONG', 37),
(18, '2024-09-18 15:05:00', 165, 3, 'SONG', 118),
(19, '2024-09-19 16:00:00', 174, 1, 'SONG', 100),
(19, '2024-09-19 16:03:00', 180, 1, 'SONG', 47),
(20, '2024-09-20 17:00:00', 231, 3, 'SONG', 58),
(20, '2024-09-20 17:04:00', 122, 3, 'SONG', 53),
(21, '2024-09-21 18:00:00', 154, 1, 'SONG', 95),
(21, '2024-09-21 18:03:00', 145, 1, 'SONG', 113),
(22, '2024-09-22 09:00:00', 254, 1, 'SONG', 1),
(23, '2024-09-23 10:00:00', 191, 1, 'SONG', 16),
(23, '2024-09-23 10:04:00', 145, 1, 'SONG', 113),
(24, '2024-09-24 11:00:00', 178, 1, 'SONG', 68),
(24, '2024-09-24 11:03:00', 253, 1, 'SONG', 54),
(25, '2024-09-25 12:04:00', 155, 1, 'SONG', 120),
(7, '2024-10-01 14:00:00', 148, 1, 'SONG', 102),
(7, '2024-10-01 14:03:00', 160, 1, 'SONG', 103),
(7, '2024-10-01 14:06:00', 193, 1, 'SONG', 83),
(5, '2024-10-02 09:00:00', 233, 3, 'SONG', 29),
(5, '2024-10-02 09:04:00', 294, 3, 'SONG', 30),
(11, '2024-10-02 18:00:00', 231, 3, 'SONG', 58),
(11, '2024-10-02 18:04:00', 338, 3, 'SONG', 59),
(11, '2024-10-02 18:10:00', 347, 3, 'SONG', 60),
(12, '2024-10-03 11:00:00', 191, 1, 'SONG', 16),
(12, '2024-10-03 11:04:00', 285, 1, 'SONG', 37),
(12, '2024-10-03 11:09:00', 148, 1, 'SONG', 79),
(13, '2024-10-04 20:00:00', 172, 1, 'SONG', 64),
(13, '2024-10-04 20:03:00', 205, 1, 'SONG', 70),
(13, '2024-10-04 20:07:00', 244, 1, 'SONG', 69),
(15, '2024-10-05 13:00:00', 179, 1, 'SONG', 27),
(15, '2024-10-05 13:03:00', 165, 1, 'SONG', 118),
(15, '2024-10-05 13:06:00', 178, 1, 'SONG', 119),
(16, '2024-10-06 15:00:00', 186, 1, 'SONG', 21),
(16, '2024-10-06 15:04:00', 145, 1, 'SONG', 121),
(16, '2024-10-06 15:07:00', 162, 1, 'SONG', 122),
(18, '2024-10-07 10:00:00', 191, 3, 'SONG', 16),
(18, '2024-10-07 10:04:00', 233, 3, 'SONG', 29),
(18, '2024-10-07 10:08:00', 165, 3, 'SONG', 118),
(19, '2024-10-08 17:00:00', 148, 1, 'SONG', 79),
(19, '2024-10-08 17:03:00', 152, 1, 'SONG', 101),
(19, '2024-10-08 17:06:00', 174, 1, 'SONG', 100),
(20, '2024-10-09 09:00:00', 191, 3, 'SONG', 16),
(20, '2024-10-09 09:04:00', 233, 3, 'SONG', 29),
(20, '2024-10-09 09:08:00', 122, 3, 'SONG', 53),
(21, '2024-10-10 14:00:00', 148, 1, 'SONG', 100),
(21, '2024-10-10 14:03:00', 154, 1, 'SONG', 95),
(21, '2024-10-10 14:06:00', 145, 1, 'SONG', 113),
(23, '2024-10-11 11:00:00', 148, 1, 'SONG', 79),
(23, '2024-10-11 11:03:00', 152, 1, 'SONG', 101),
(23, '2024-10-11 11:06:00', 158, 1, 'SONG', 111),
(24, '2024-10-12 16:00:00', 172, 1, 'SONG', 64),
(24, '2024-10-12 16:03:00', 178, 1, 'SONG', 68),
(24, '2024-10-12 16:07:00', 253, 1, 'SONG', 54),
(25, '2024-10-13 18:04:00', 233, 1, 'SONG', 39),
(25, '2024-10-13 18:08:00', 155, 1, 'SONG', 120),
(1, '2024-10-14 08:00:00', 233, 1, 'SONG', 39),
(1, '2024-10-14 08:04:00', 191, 1, 'SONG', 16),
(2, '2024-10-15 10:00:00', 225, 3, 'SONG', 7),
(2, '2024-10-15 10:04:00', 148, 3, 'SONG', 79),
(3, '2024-10-16 12:00:00', 212, 1, 'SONG', 6),
(3, '2024-10-16 12:04:00', 148, 1, 'SONG', 79),
(4, '2024-10-17 15:00:00', 172, 1, 'SONG', 64),
(4, '2024-10-17 15:03:00', 295, 1, 'SONG', 65),
(7, '2024-11-01 12:00:00', 218, 1, 'SONG', 81),
(7, '2024-11-01 12:03:30', 116, 1, 'SONG', 82),
(7, '2024-11-01 12:05:30', 193, 1, 'SONG', 83),
(4, '2024-11-02 10:00:00', 179, 1, 'SONG', 27),
(4, '2024-11-02 10:03:00', 190, 1, 'SONG', 28),
(4, '2024-11-02 10:06:00', 190, 1, 'SONG', 23),
(10, '2024-11-03 16:00:00', 174, 1, 'SONG', 100),
(10, '2024-11-03 16:03:00', 152, 1, 'SONG', 101),
(10, '2024-11-03 16:05:30', 148, 1, 'SONG', 102),
(15, '2024-11-03 18:00:00', 179, 1, 'SONG', 27),
(15, '2024-11-03 18:03:00', 198, 1, 'SONG', 42),
(15, '2024-11-03 18:06:30', 155, 1, 'SONG', 120),
(11, '2024-11-04 14:00:00', 231, 3, 'SONG', 58),
(11, '2024-11-04 14:04:00', 338, 3, 'SONG', 59),
(11, '2024-11-04 14:10:00', 347, 3, 'SONG', 60),
(19, '2024-11-05 17:00:00', 148, 1, 'SONG', 79),
(19, '2024-11-05 17:02:30', 152, 1, 'SONG', 101),
(19, '2024-11-05 17:05:00', 160, 1, 'SONG', 103),
(21, '2024-11-06 19:00:00', 148, 3, 'SONG', 100),
(21, '2024-11-06 19:03:00', 160, 3, 'SONG', 103),
(21, '2024-11-06 19:06:00', 172, 3, 'SONG', 108),
(5, '2024-11-07 09:00:00', 233, 1, 'SONG', 29),
(5, '2024-11-07 09:04:00', 294, 1, 'SONG', 30),
(23, '2024-11-08 20:00:00', 191, 1, 'SONG', 16),
(23, '2024-11-08 20:03:30', 186, 1, 'SONG', 21),
(23, '2024-11-08 20:06:30', 148, 1, 'SONG', 79),
(12, '2024-11-09 11:00:00', 191, 1, 'SONG', 16),
(12, '2024-11-09 11:03:30', 148, 1, 'SONG', 79),
(12, '2024-11-09 11:06:00', 148, 1, 'SONG', 102),
(1, '2024-11-10 13:00:00', 191, 1, 'SONG', 16),
(1, '2024-11-10 13:03:30', 233, 1, 'SONG', 29),
(1, '2024-11-10 13:07:30', 170, 1, 'SONG', 44),
(2, '2024-11-11 15:00:00', 254, 3, 'SONG', 1),
(2, '2024-11-11 15:04:30', 119, 3, 'SONG', 80),
(2, '2024-11-11 15:06:30', 218, 3, 'SONG', 81),
(3, '2024-11-12 08:00:00', 254, 1, 'SONG', 1),
(3, '2024-11-12 08:04:30', 148, 1, 'SONG', 79),
(3, '2024-11-12 08:07:00', 174, 1, 'SONG', 100),
(13, '2024-11-13 21:00:00', 172, 1, 'SONG', 64),
(13, '2024-11-13 21:03:00', 295, 1, 'SONG', 65),
(13, '2024-11-13 21:08:00', 180, 1, 'SONG', 47),
(24, '2024-11-14 14:00:00', 172, 1, 'SONG', 64),
(24, '2024-11-14 14:03:00', 178, 1, 'SONG', 68),
(24, '2024-11-14 14:06:00', 253, 1, 'SONG', 54),
(25, '2024-11-15 16:00:00', 200, 1, 'SONG', 38),
(25, '2024-11-15 16:03:30', 233, 1, 'SONG', 39),
(25, '2024-11-15 16:07:30', 155, 1, 'SONG', 120),
(6, '2024-11-16 12:00:00', 186, 1, 'SONG', 21),
(6, '2024-11-16 12:03:30', 253, 1, 'SONG', 54),
(7, '2024-11-01 12:00:00', 218, 1, 'SONG', 81),
(7, '2024-11-01 12:03:30', 116, 1, 'SONG', 82),
(7, '2024-11-01 12:05:30', 193, 1, 'SONG', 83),
(4, '2024-11-02 10:00:00', 179, 1, 'SONG', 27),
(4, '2024-11-02 10:03:00', 190, 1, 'SONG', 28),
(4, '2024-11-02 10:06:00', 190, 1, 'SONG', 23),
(10, '2024-11-03 16:00:00', 174, 1, 'SONG', 100),
(10, '2024-11-03 16:03:00', 152, 1, 'SONG', 101),
(10, '2024-11-03 16:05:30', 148, 1, 'SONG', 102),
(15, '2024-11-03 18:00:00', 179, 1, 'SONG', 27),
(15, '2024-11-03 18:03:00', 198, 1, 'SONG', 42),
(15, '2024-11-03 18:06:30', 155, 1, 'SONG', 120),
(11, '2024-11-04 14:00:00', 231, 3, 'SONG', 58),
(11, '2024-11-04 14:04:00', 338, 3, 'SONG', 59),
(11, '2024-11-04 14:10:00', 347, 3, 'SONG', 60),
(19, '2024-11-05 17:00:00', 148, 1, 'SONG', 79),
(19, '2024-11-05 17:02:30', 152, 1, 'SONG', 101),
(19, '2024-11-05 17:05:00', 160, 1, 'SONG', 103),
(21, '2024-11-06 19:00:00', 148, 3, 'SONG', 100),
(21, '2024-11-06 19:03:00', 160, 3, 'SONG', 103),
(21, '2024-11-06 19:06:00', 172, 3, 'SONG', 108),
(5, '2024-11-07 09:00:00', 233, 1, 'SONG', 29),
(5, '2024-11-07 09:04:00', 294, 1, 'SONG', 30),
(23, '2024-11-08 20:00:00', 191, 1, 'SONG', 16),
(23, '2024-11-08 20:03:30', 186, 1, 'SONG', 21),
(23, '2024-11-08 20:06:30', 148, 1, 'SONG', 79),
(12, '2024-11-09 11:00:00', 191, 1, 'SONG', 16),
(12, '2024-11-09 11:03:30', 148, 1, 'SONG', 79),
(12, '2024-11-09 11:06:00', 148, 1, 'SONG', 102),
(1, '2024-11-10 13:00:00', 191, 1, 'SONG', 16),
(1, '2024-11-10 13:03:30', 233, 1, 'SONG', 29),
(1, '2024-11-10 13:07:30', 170, 1, 'SONG', 44),
(2, '2024-11-11 15:00:00', 254, 3, 'SONG', 1),
(2, '2024-11-11 15:04:30', 119, 3, 'SONG', 80),
(2, '2024-11-11 15:06:30', 218, 3, 'SONG', 81),
(3, '2024-11-12 08:00:00', 254, 1, 'SONG', 1),
(3, '2024-11-12 08:04:30', 148, 1, 'SONG', 79),
(3, '2024-11-12 08:07:00', 174, 1, 'SONG', 100),
(13, '2024-11-13 21:00:00', 172, 1, 'SONG', 64),
(13, '2024-11-13 21:03:00', 295, 1, 'SONG', 65),
(13, '2024-11-13 21:08:00', 180, 1, 'SONG', 47),
(24, '2024-11-14 14:00:00', 172, 1, 'SONG', 64),
(24, '2024-11-14 14:03:00', 178, 1, 'SONG', 68),
(24, '2024-11-14 14:06:00', 253, 1, 'SONG', 54),
(25, '2024-11-15 16:00:00', 200, 1, 'SONG', 38),
(25, '2024-11-15 16:03:30', 233, 1, 'SONG', 39),
(25, '2024-11-15 16:07:30', 155, 1, 'SONG', 120),
(6, '2024-11-16 12:00:00', 186, 1, 'SONG', 21),
(6, '2024-11-16 12:03:30', 253, 1, 'SONG', 54),
(7, '2025-01-01 12:00:00', 148, 1, 'SONG', 79),
(7, '2025-01-01 12:03:00', 218, 1, 'SONG', 81),
(7, '2025-01-01 12:07:00', 193, 1, 'SONG', 83),
(10, '2025-01-02 10:00:00', 174, 1, 'SONG', 100),
(10, '2025-01-02 10:03:00', 152, 1, 'SONG', 101),
(10, '2025-01-02 10:06:00', 160, 1, 'SONG', 103),
(11, '2025-01-02 15:00:00', 231, 3, 'SONG', 58),
(11, '2025-01-02 15:04:00', 338, 3, 'SONG', 59),
(11, '2025-01-02 15:10:00', 238, 3, 'SONG', 61),
(19, '2025-01-03 16:00:00', 148, 1, 'SONG', 79),
(19, '2025-01-03 16:03:00', 180, 1, 'SONG', 47),
(19, '2025-01-03 16:07:00', 152, 1, 'SONG', 101),
(21, '2025-01-03 18:00:00', 148, 3, 'SONG', 100),
(21, '2025-01-03 18:03:00', 154, 3, 'SONG', 95),
(21, '2025-01-03 18:06:00', 145, 3, 'SONG', 113),
(1, '2025-01-04 09:00:00', 191, 1, 'SONG', 16),
(1, '2025-01-04 09:03:30', 233, 1, 'SONG', 29),
(1, '2025-01-04 09:08:00', 285, 1, 'SONG', 37),
(2, '2025-01-05 11:00:00', 254, 3, 'SONG', 1),
(2, '2025-01-05 11:04:30', 225, 3, 'SONG', 7),
(2, '2025-01-05 11:08:30', 148, 3, 'SONG', 79),
(3, '2025-01-06 08:00:00', 254, 1, 'SONG', 1),
(3, '2025-01-06 08:04:30', 148, 1, 'SONG', 79),
(3, '2025-01-06 08:07:00', 174, 1, 'SONG', 100),
(4, '2025-01-07 14:00:00', 172, 1, 'SONG', 64),
(4, '2025-01-07 14:03:00', 179, 1, 'SONG', 27),
(4, '2025-01-07 14:06:30', 190, 1, 'SONG', 23),
(5, '2025-01-08 10:00:00', 233, 1, 'SONG', 29),
(5, '2025-01-08 10:04:00', 294, 1, 'SONG', 30),
(5, '2025-01-08 10:09:00', 148, 1, 'SONG', 79),
(6, '2025-01-09 12:00:00', 186, 1, 'SONG', 21),
(6, '2025-01-09 12:03:30', 253, 1, 'SONG', 54),
(6, '2025-01-09 12:08:00', 194, 1, 'SONG', 56),
(8, '2025-01-10 13:00:00', 172, 3, 'SONG', 64),
(8, '2025-01-10 13:03:00', 180, 3, 'SONG', 47),
(8, '2025-01-10 13:06:30', 192, 3, 'SONG', 50),
(9, '2025-01-11 15:00:00', 191, 1, 'SONG', 16),
(9, '2025-01-11 15:03:30', 190, 1, 'SONG', 23),
(9, '2025-01-11 15:07:00', 179, 1, 'SONG', 27),
(12, '2025-01-12 09:00:00', 148, 1, 'SONG', 79),
(12, '2025-01-12 09:02:30', 218, 1, 'SONG', 81),
(12, '2025-01-12 09:06:30', 155, 1, 'SONG', 104),
(13, '2025-01-13 19:00:00', 172, 1, 'SONG', 64),
(13, '2025-01-13 19:03:00', 295, 1, 'SONG', 65),
(13, '2025-01-13 19:08:00', 205, 1, 'SONG', 70),
(14, '2025-01-14 11:00:00', 233, 1, 'SONG', 29),
(15, '2025-01-15 13:00:00', 179, 1, 'SONG', 27),
(15, '2025-01-15 13:03:00', 200, 1, 'SONG', 38),
(15, '2025-01-15 13:06:30', 233, 1, 'SONG', 39),
(13, '2025-03-14 10:00:00', 180, 1, 'SONG', 90),
(13, '2025-03-14 10:03:00', 175, 1, 'SONG', 91),
(13, '2025-03-14 10:06:00', 210, 1, 'SONG', 92),
(14, '2025-03-14 11:00:00', 165, 1, 'SONG', 93),
(14, '2025-03-14 11:03:00', 129, 1, 'SONG', 94),
(18, '2025-05-09 09:00:00', 162, 1, 'SONG', 122),
(18, '2025-05-09 09:03:00', 158, 1, 'SONG', 123),
(18, '2025-05-09 09:06:00', 170, 1, 'SONG', 124),
(7, '2025-02-10 14:00:00', 180, 1, 'SONG', 90),
(7, '2025-02-10 14:03:00', 175, 1, 'SONG', 91),
(7, '2025-02-10 14:06:00', 193, 1, 'SONG', 83),
(10, '2025-02-11 15:00:00', 148, 1, 'SONG', 79),
(10, '2025-02-11 15:03:00', 152, 1, 'SONG', 101),
(10, '2025-02-11 15:06:00', 160, 1, 'SONG', 103),
(11, '2025-02-12 10:00:00', 231, 3, 'SONG', 58),
(11, '2025-02-12 10:04:00', 338, 3, 'SONG', 59),
(11, '2025-02-12 10:10:00', 238, 3, 'SONG', 61),
(19, '2025-02-13 18:00:00', 148, 1, 'SONG', 79),
(19, '2025-02-13 18:03:00', 152, 1, 'SONG', 101),
(19, '2025-02-13 18:06:00', 174, 1, 'SONG', 100),
(21, '2025-02-14 09:00:00', 148, 3, 'SONG', 100),
(21, '2025-02-14 09:03:00', 160, 3, 'SONG', 103),
(21, '2025-02-14 09:06:00', 122, 3, 'SONG', 53),
(23, '2025-02-15 11:00:00', 191, 1, 'SONG', 16),
(23, '2025-02-15 11:03:00', 148, 1, 'SONG', 79),
(23, '2025-02-15 11:06:00', 148, 1, 'SONG', 100),
(1, '2025-02-16 08:00:00', 191, 1, 'SONG', 16),
(1, '2025-02-16 08:03:30', 233, 1, 'SONG', 29),
(1, '2025-02-16 08:07:30', 170, 1, 'SONG', 44),
(2, '2025-02-17 12:00:00', 254, 3, 'SONG', 1),
(2, '2025-02-17 12:04:30', 225, 3, 'SONG', 7),
(2, '2025-02-17 12:08:30', 148, 3, 'SONG', 79),
(3, '2025-02-18 10:00:00', 254, 1, 'SONG', 1),
(3, '2025-02-18 10:04:30', 148, 1, 'SONG', 79),
(3, '2025-02-18 10:07:00', 174, 1, 'SONG', 100),
(4, '2025-02-19 14:00:00', 172, 1, 'SONG', 64),
(4, '2025-02-19 14:03:00', 245, 1, 'SONG', 67),
(4, '2025-02-19 14:07:00', 179, 1, 'SONG', 27),
(5, '2025-02-20 16:00:00', 233, 1, 'SONG', 29),
(5, '2025-02-20 16:04:00', 294, 1, 'SONG', 30),
(5, '2025-02-20 16:09:00', 180, 1, 'SONG', 90),
(6, '2025-02-21 08:00:00', 186, 1, 'SONG', 21),
(6, '2025-02-21 08:03:30', 253, 1, 'SONG', 54),
(6, '2025-02-21 08:08:00', 211, 1, 'SONG', 55),
(8, '2025-02-22 11:00:00', 172, 3, 'SONG', 64),
(8, '2025-02-22 11:03:00', 178, 3, 'SONG', 68),
(8, '2025-02-22 11:06:30', 192, 3, 'SONG', 50),
(9, '2025-02-23 15:00:00', 191, 1, 'SONG', 16),
(9, '2025-02-23 15:03:30', 190, 1, 'SONG', 23),
(9, '2025-02-23 15:07:00', 179, 1, 'SONG', 27),
(13, '2025-06-15 20:00:00', 148, 1, 'SONG', 79),
(13, '2025-06-15 20:03:00', 175, 1, 'SONG', 91),
(13, '2025-06-15 20:06:00', 129, 1, 'SONG', 94),
(14, '2025-07-20 18:00:00', 210, 1, 'SONG', 92),
(14, '2025-07-20 18:04:00', 165, 1, 'SONG', 93),
(14, '2025-07-20 18:07:00', 152, 1, 'SONG', 101),
(18, '2025-08-12 14:00:00', 162, 1, 'SONG', 122),
(18, '2025-08-12 14:03:00', 170, 1, 'SONG', 124),
(18, '2025-08-12 14:06:30', 145, 1, 'SONG', 121),
(7, '2025-06-01 10:00:00', 180, 1, 'SONG', 90),
(7, '2025-06-01 10:03:00', 193, 1, 'SONG', 83),
(7, '2025-06-01 10:07:00', 148, 1, 'SONG', 100),
(10, '2025-06-02 11:00:00', 174, 1, 'SONG', 100),
(10, '2025-06-02 11:03:00', 195, 1, 'SONG', 107),
(10, '2025-06-02 11:07:00', 160, 1, 'SONG', 103),
(11, '2025-06-03 12:00:00', 231, 3, 'SONG', 58),
(11, '2025-06-03 12:04:00', 338, 3, 'SONG', 59),
(11, '2025-06-03 12:10:00', 347, 3, 'SONG', 60),
(15, '2025-06-04 13:00:00', 200, 1, 'SONG', 38),
(15, '2025-06-04 13:04:00', 233, 1, 'SONG', 39),
(15, '2025-06-04 13:08:00', 165, 1, 'SONG', 118),
(16, '2025-06-05 15:00:00', 145, 1, 'SONG', 121),
(16, '2025-06-05 15:03:00', 162, 1, 'SONG', 122),
(16, '2025-06-05 15:06:00', 170, 1, 'SONG', 124),
(19, '2025-06-06 16:00:00', 148, 1, 'SONG', 79),
(19, '2025-06-06 16:03:00', 174, 1, 'SONG', 100),
(19, '2025-06-06 16:07:00', 152, 1, 'SONG', 101),
(21, '2025-06-07 09:00:00', 148, 3, 'SONG', 100),
(21, '2025-06-07 09:03:00', 154, 3, 'SONG', 95),
(21, '2025-06-07 09:06:00', 145, 3, 'SONG', 113),
(23, '2025-06-08 11:00:00', 191, 1, 'SONG', 16),
(23, '2025-06-08 11:03:00', 148, 1, 'SONG', 79),
(23, '2025-06-08 11:06:00', 148, 1, 'SONG', 102),
(25, '2025-06-09 14:04:00', 153, 1, 'SONG', 43),
(25, '2025-06-09 14:07:30', 155, 1, 'SONG', 120),
(1, '2025-07-01 10:00:00', 191, 1, 'SONG', 16),
(1, '2025-07-01 10:03:30', 233, 1, 'SONG', 29),
(2, '2025-07-02 12:00:00', 254, 3, 'SONG', 1),
(2, '2025-07-02 12:04:30', 225, 3, 'SONG', 7),
(3, '2025-07-03 08:00:00', 254, 1, 'SONG', 1),
(3, '2025-07-03 08:04:30', 148, 1, 'SONG', 79),
(4, '2025-07-04 11:00:00', 172, 1, 'SONG', 64),
(4, '2025-07-04 11:03:30', 245, 1, 'SONG', 67),
(5, '2025-07-05 09:00:00', 233, 1, 'SONG', 29),
(5, '2025-07-05 09:04:00', 294, 1, 'SONG', 30),
(6, '2025-07-06 13:00:00', 186, 1, 'SONG', 21),
(6, '2025-07-06 13:03:30', 253, 1, 'SONG', 54),
(8, '2025-07-07 10:00:00', 172, 3, 'SONG', 64),
(8, '2025-07-07 10:03:30', 180, 3, 'SONG', 47),
(1, '2025-09-01 08:00:00', 233, 1, 'SONG', 29),
(1, '2025-09-01 08:04:00', 294, 1, 'SONG', 30),
(2, '2025-09-02 10:00:00', 254, 3, 'SONG', 1),
(2, '2025-09-02 10:05:00', 347, 3, 'SONG', 2),
(3, '2025-09-03 14:00:00', 148, 1, 'SONG', 79),
(3, '2025-09-03 14:03:00', 218, 1, 'SONG', 81),
(4, '2025-09-04 11:00:00', 172, 1, 'SONG', 64),
(4, '2025-09-04 11:03:00', 295, 1, 'SONG', 65),
(5, '2025-09-05 09:00:00', 233, 1, 'SONG', 29),
(5, '2025-09-05 09:04:00', 254, 1, 'SONG', 1),
(6, '2025-09-06 13:00:00', 186, 1, 'SONG', 21),
(6, '2025-09-06 13:04:00', 253, 1, 'SONG', 54),
(7, '2025-09-07 15:00:00', 174, 1, 'SONG', 100),
(7, '2025-09-07 15:03:00', 152, 1, 'SONG', 101),
(8, '2025-09-08 17:00:00', 172, 3, 'SONG', 64),
(8, '2025-09-08 17:03:00', 178, 3, 'SONG', 68),
(9, '2025-09-09 12:00:00', 191, 1, 'SONG', 16),
(9, '2025-09-09 12:04:00', 190, 1, 'SONG', 23),
(10, '2025-09-10 19:00:00', 148, 1, 'SONG', 79),
(10, '2025-09-10 19:03:00', 160, 1, 'SONG', 103),
(11, '2025-09-11 10:00:00', 231, 3, 'SONG', 58),
(11, '2025-09-11 10:04:00', 338, 3, 'SONG', 59),
(12, '2025-09-12 11:00:00', 191, 1, 'SONG', 16),
(12, '2025-09-12 11:04:00', 148, 1, 'SONG', 79),
(13, '2025-09-13 20:00:00', 172, 1, 'SONG', 64),
(13, '2025-09-13 20:03:00', 244, 1, 'SONG', 69),
(14, '2025-09-14 11:00:00', 145, 1, 'SONG', 121),
(14, '2025-09-14 11:03:00', 162, 1, 'SONG', 122),
(15, '2025-09-15 13:00:00', 179, 1, 'SONG', 27),
(15, '2025-09-15 13:03:00', 200, 1, 'SONG', 38),
(16, '2025-09-16 15:00:00', 162, 1, 'SONG', 122),
(16, '2025-09-16 15:03:00', 170, 1, 'SONG', 124),
(17, '2025-09-17 14:00:00', 254, 4, 'SONG', 1),
(17, '2025-09-17 14:04:00', 172, 4, 'SONG', 64),
(18, '2025-09-18 10:00:00', 145, 1, 'SONG', 121),
(18, '2025-09-18 10:03:00', 178, 1, 'SONG', 119),
(19, '2025-09-19 16:00:00', 148, 1, 'SONG', 79),
(19, '2025-09-19 16:03:00', 174, 1, 'SONG', 100),
(20, '2025-09-20 09:00:00', 231, 3, 'SONG', 58),
(20, '2025-09-20 09:04:00', 122, 3, 'SONG', 53),
(21, '2025-09-21 11:00:00', 148, 3, 'SONG', 100),
(21, '2025-09-21 11:03:00', 154, 3, 'SONG', 95),
(22, '2025-09-22 08:00:00', 190, 1, 'SONG', 23),
(22, '2025-09-22 08:04:00', 254, 1, 'SONG', 1),
(23, '2025-09-23 14:00:00', 191, 1, 'SONG', 16),
(23, '2025-09-23 14:03:00', 148, 1, 'SONG', 79),
(24, '2025-09-24 16:00:00', 172, 1, 'SONG', 64),
(24, '2025-09-24 16:03:00', 253, 1, 'SONG', 54),
(25, '2025-09-25 10:03:00', 155, 1, 'SONG', 120),
(13, '2025-11-15 10:00:00', 180, 1, 'SONG', 90),
(13, '2025-11-15 10:03:00', 210, 1, 'SONG', 92),
(13, '2025-11-15 10:07:00', 148, 1, 'SONG', 79),
(14, '2025-11-16 11:00:00', 165, 1, 'SONG', 93),
(14, '2025-11-16 11:03:00', 129, 1, 'SONG', 94),
(14, '2025-11-16 11:06:00', 148, 1, 'SONG', 79),
(18, '2025-12-01 09:00:00', 162, 1, 'SONG', 122),
(18, '2025-12-01 09:03:00', 158, 1, 'SONG', 123),
(18, '2025-12-01 09:06:00', 170, 1, 'SONG', 124),
(7, '2025-12-02 14:00:00', 180, 1, 'SONG', 90),
(7, '2025-12-02 14:03:00', 193, 1, 'SONG', 83),
(7, '2025-12-02 14:07:00', 174, 1, 'SONG', 100),
(10, '2025-12-03 15:00:00', 148, 1, 'SONG', 79),
(10, '2025-12-03 15:03:00', 152, 1, 'SONG', 101),
(10, '2025-12-03 15:06:00', 138, 1, 'SONG', 117),
(11, '2025-12-04 10:00:00', 231, 3, 'SONG', 58),
(11, '2025-12-04 10:04:00', 338, 3, 'SONG', 59),
(11, '2025-12-04 10:10:00', 238, 3, 'SONG', 61),
(19, '2025-12-05 18:00:00', 148, 1, 'SONG', 79),
(19, '2025-12-05 18:03:00', 152, 1, 'SONG', 101),
(19, '2025-12-05 18:06:00', 180, 1, 'SONG', 47),
(21, '2025-12-06 09:00:00', 148, 3, 'SONG', 100),
(21, '2025-12-06 09:03:00', 160, 3, 'SONG', 103),
(21, '2025-12-06 09:06:00', 145, 3, 'SONG', 113),
(23, '2025-12-07 11:00:00', 191, 1, 'SONG', 16),
(23, '2025-12-07 11:03:00', 148, 1, 'SONG', 79),
(23, '2025-12-07 11:06:00', 148, 1, 'SONG', 100),
(25, '2025-12-08 14:04:00', 153, 1, 'SONG', 43),
(25, '2025-12-08 14:07:30', 155, 1, 'SONG', 120),
(1, '2025-01-05 10:00:00', 191, 1, 'SONG', 16),
(1, '2025-01-05 10:03:30', 233, 1, 'SONG', 29),
(2, '2025-01-06 12:00:00', 254, 3, 'SONG', 1),
(2, '2025-01-06 12:04:30', 225, 3, 'SONG', 7),
(3, '2025-01-07 08:00:00', 254, 1, 'SONG', 1),
(3, '2025-01-07 08:04:30', 148, 1, 'SONG', 79),
(4, '2025-01-08 11:00:00', 172, 1, 'SONG', 64),
(4, '2025-01-08 11:03:30', 245, 1, 'SONG', 67),
(5, '2025-01-09 09:00:00', 233, 1, 'SONG', 29),
(5, '2025-01-09 09:04:00', 294, 1, 'SONG', 30),
(6, '2025-01-10 13:00:00', 186, 1, 'SONG', 21),
(6, '2025-01-10 13:03:30', 253, 1, 'SONG', 54),
(8, '2025-01-11 10:00:00', 172, 3, 'SONG', 64),
(8, '2025-01-11 10:03:30', 180, 3, 'SONG', 47),
(9, '2025-01-12 14:00:00', 191, 1, 'SONG', 16),
(9, '2025-01-12 14:04:00', 179, 1, 'SONG', 27),
(12, '2025-01-13 16:00:00', 148, 1, 'SONG', 79),
(12, '2025-01-13 16:02:30', 218, 1, 'SONG', 81),
(15, '2025-01-14 17:00:00', 200, 1, 'SONG', 38),
(15, '2025-01-14 17:03:30', 233, 1, 'SONG', 39),
(13, '2025-02-01 10:00:00', 180, 1, 'SONG', 90),
(13, '2025-02-01 10:03:00', 175, 1, 'SONG', 91),
(13, '2025-02-01 10:06:00', 148, 1, 'SONG', 79),
(14, '2025-02-02 11:00:00', 210, 1, 'SONG', 92),
(14, '2025-02-02 11:03:30', 165, 1, 'SONG', 93),
(14, '2025-02-02 11:06:00', 148, 1, 'SONG', 100),
(18, '2025-02-03 14:00:00', 162, 1, 'SONG', 122),
(18, '2025-02-03 14:03:00', 158, 1, 'SONG', 123),
(18, '2025-02-03 14:06:00', 170, 1, 'SONG', 124),
(7, '2025-02-04 15:00:00', 180, 1, 'SONG', 90),
(7, '2025-02-04 15:03:00', 175, 1, 'SONG', 91),
(7, '2025-02-04 15:06:00', 193, 1, 'SONG', 83),
(10, '2025-02-05 16:00:00', 148, 1, 'SONG', 79),
(10, '2025-02-05 16:03:00', 152, 1, 'SONG', 101),
(10, '2025-02-05 16:06:00', 160, 1, 'SONG', 103),
(11, '2025-02-06 10:00:00', 231, 3, 'SONG', 58),
(11, '2025-02-06 10:04:00', 338, 3, 'SONG', 59),
(11, '2025-02-06 10:10:00', 238, 3, 'SONG', 61),
(19, '2025-02-07 18:00:00', 148, 1, 'SONG', 79),
(19, '2025-02-07 18:03:00', 152, 1, 'SONG', 101),
(19, '2025-02-07 18:06:00', 180, 1, 'SONG', 47),
(21, '2025-02-08 09:00:00', 148, 3, 'SONG', 100),
(21, '2025-02-08 09:03:00', 160, 3, 'SONG', 103),
(21, '2025-02-08 09:06:00', 145, 3, 'SONG', 113),
(23, '2025-02-09 11:00:00', 191, 1, 'SONG', 16),
(23, '2025-02-09 11:03:00', 148, 1, 'SONG', 79),
(23, '2025-02-09 11:06:00', 148, 1, 'SONG', 100),
(25, '2025-02-10 14:04:00', 153, 1, 'SONG', 43),
(25, '2025-02-10 14:07:30', 155, 1, 'SONG', 120),
(1, '2025-02-11 08:00:00', 191, 1, 'SONG', 16),
(1, '2025-02-11 08:03:30', 233, 1, 'SONG', 29),
(2, '2025-02-12 12:00:00', 254, 3, 'SONG', 1),
(2, '2025-02-12 12:04:30', 225, 3, 'SONG', 7),
(3, '2025-02-13 08:00:00', 254, 1, 'SONG', 1),
(3, '2025-02-13 08:04:30', 148, 1, 'SONG', 79),
(4, '2025-02-14 11:00:00', 172, 1, 'SONG', 64),
(4, '2025-02-14 11:03:30', 245, 1, 'SONG', 67),
(5, '2025-02-15 09:00:00', 233, 1, 'SONG', 29),
(5, '2025-02-15 09:04:00', 254, 1, 'SONG', 1),
(6, '2025-02-16 13:00:00', 186, 1, 'SONG', 21),
(6, '2025-02-16 13:03:30', 253, 1, 'SONG', 54),
(8, '2025-02-17 10:00:00', 172, 3, 'SONG', 64),
(8, '2025-02-17 10:03:30', 180, 3, 'SONG', 47),
(9, '2025-02-18 14:00:00', 191, 1, 'SONG', 16),
(9, '2025-02-18 14:04:00', 179, 1, 'SONG', 27),
(12, '2025-02-19 16:00:00', 148, 1, 'SONG', 79),
(12, '2025-02-19 16:02:30', 218, 1, 'SONG', 81),
(15, '2025-02-20 17:00:00', 200, 1, 'SONG', 38),
(15, '2025-02-20 17:03:30', 233, 1, 'SONG', 39),
(13, '2025-03-14 20:00:00', 180, 1, 'SONG', 90),
(13, '2025-03-14 20:03:00', 175, 1, 'SONG', 91),
(13, '2025-03-14 20:06:00', 210, 1, 'SONG', 92),
(14, '2025-03-15 18:00:00', 165, 1, 'SONG', 93),
(14, '2025-03-15 18:03:00', 129, 1, 'SONG', 94),
(14, '2025-03-15 18:06:00', 148, 1, 'SONG', 102),
(18, '2025-05-09 21:00:00', 162, 1, 'SONG', 122),
(18, '2025-05-09 21:03:00', 158, 1, 'SONG', 123),
(18, '2025-05-09 21:06:00', 170, 1, 'SONG', 124),
(7, '2025-03-20 14:00:00', 180, 1, 'SONG', 90),
(7, '2025-03-20 14:03:00', 175, 1, 'SONG', 91),
(7, '2025-03-20 14:06:00', 180, 1, 'SONG', 47),
(10, '2025-03-21 15:00:00', 148, 1, 'SONG', 79),
(10, '2025-03-21 15:03:00', 174, 1, 'SONG', 100),
(10, '2025-03-21 15:06:00', 160, 1, 'SONG', 103),
(11, '2025-03-22 10:00:00', 231, 3, 'SONG', 58),
(11, '2025-03-22 10:04:00', 338, 3, 'SONG', 59),
(11, '2025-03-22 10:10:00', 238, 3, 'SONG', 61),
(19, '2025-03-23 18:00:00', 148, 1, 'SONG', 79),
(19, '2025-03-23 18:03:00', 152, 1, 'SONG', 101),
(19, '2025-03-23 18:06:00', 180, 1, 'SONG', 47),
(21, '2025-03-24 09:00:00', 148, 3, 'SONG', 100),
(21, '2025-03-24 09:03:00', 160, 3, 'SONG', 103),
(21, '2025-03-24 09:06:00', 145, 3, 'SONG', 113),
(23, '2025-03-25 11:00:00', 191, 1, 'SONG', 16),
(23, '2025-03-25 11:03:00', 148, 1, 'SONG', 79),
(23, '2025-03-25 11:06:00', 148, 1, 'SONG', 100),
(25, '2025-03-26 14:04:00', 153, 1, 'SONG', 43),
(25, '2025-03-26 14:07:30', 155, 1, 'SONG', 120),
(1, '2025-04-01 08:00:00', 191, 1, 'SONG', 16),
(1, '2025-04-01 08:03:30', 233, 1, 'SONG', 29),
(2, '2025-04-02 12:00:00', 254, 3, 'SONG', 1),
(2, '2025-04-02 12:04:30', 225, 3, 'SONG', 7),
(3, '2025-04-03 08:00:00', 254, 1, 'SONG', 1),
(3, '2025-04-03 08:04:30', 148, 1, 'SONG', 79),
(4, '2025-04-04 11:00:00', 172, 1, 'SONG', 64),
(4, '2025-04-04 11:03:30', 245, 1, 'SONG', 67),
(5, '2025-04-05 09:00:00', 233, 1, 'SONG', 29),
(5, '2025-04-05 09:04:00', 254, 1, 'SONG', 1),
(6, '2025-04-06 13:00:00', 186, 1, 'SONG', 21),
(6, '2025-04-06 13:03:30', 253, 1, 'SONG', 54),
(8, '2025-04-07 10:00:00', 172, 3, 'SONG', 64),
(8, '2025-04-07 10:03:30', 180, 3, 'SONG', 47),
(9, '2025-04-08 14:00:00', 191, 1, 'SONG', 16),
(9, '2025-04-08 14:04:00', 179, 1, 'SONG', 27),
(12, '2025-04-09 16:00:00', 148, 1, 'SONG', 79),
(12, '2025-04-09 16:02:30', 218, 1, 'SONG', 81),
(15, '2025-04-10 17:00:00', 200, 1, 'SONG', 38),
(15, '2025-04-10 17:03:30', 233, 1, 'SONG', 39),
(13, '2025-05-15 10:00:00', 180, 1, 'SONG', 90),
(13, '2025-05-15 10:03:00', 210, 1, 'SONG', 92),
(13, '2025-05-15 10:07:00', 129, 1, 'SONG', 94),
(14, '2025-05-16 11:00:00', 175, 1, 'SONG', 91),
(14, '2025-05-16 11:03:00', 165, 1, 'SONG', 93),
(14, '2025-05-16 11:06:00', 148, 1, 'SONG', 79),
(18, '2025-06-01 09:00:00', 162, 1, 'SONG', 122),
(18, '2025-06-01 09:03:00', 158, 1, 'SONG', 123),
(18, '2025-06-01 09:06:00', 170, 1, 'SONG', 124),
(7, '2025-05-10 14:00:00', 180, 1, 'SONG', 90),
(7, '2025-05-10 14:03:00', 129, 1, 'SONG', 94),
(7, '2025-05-10 14:06:00', 193, 1, 'SONG', 83),
(10, '2025-05-11 15:00:00', 148, 1, 'SONG', 79),
(10, '2025-05-11 15:03:00', 210, 1, 'SONG', 92),
(10, '2025-05-11 15:06:00', 160, 1, 'SONG', 103),
(11, '2025-05-12 10:00:00', 231, 3, 'SONG', 58),
(11, '2025-05-12 10:04:00', 338, 3, 'SONG', 59),
(11, '2025-05-12 10:10:00', 238, 3, 'SONG', 61),
(19, '2025-05-13 18:00:00', 148, 1, 'SONG', 79),
(19, '2025-05-13 18:03:00', 175, 1, 'SONG', 91),
(19, '2025-05-13 18:06:00', 180, 1, 'SONG', 47),
(21, '2025-05-14 09:00:00', 148, 3, 'SONG', 100),
(21, '2025-05-14 09:03:00', 160, 3, 'SONG', 103),
(21, '2025-05-14 09:06:00', 129, 3, 'SONG', 94),
(23, '2025-05-15 11:00:00', 191, 1, 'SONG', 16),
(23, '2025-05-15 11:03:00', 148, 1, 'SONG', 79),
(23, '2025-05-15 11:06:00', 180, 1, 'SONG', 90),
(25, '2025-05-16 14:04:00', 162, 1, 'SONG', 122),
(25, '2025-05-16 14:07:30', 155, 1, 'SONG', 120),
(1, '2025-06-05 08:00:00', 191, 1, 'SONG', 16),
(1, '2025-06-05 08:03:30', 233, 1, 'SONG', 29),
(2, '2025-06-06 12:00:00', 254, 3, 'SONG', 1),
(2, '2025-06-06 12:04:30', 225, 3, 'SONG', 7),
(3, '2025-06-07 08:00:00', 254, 1, 'SONG', 1),
(3, '2025-06-07 08:04:30', 148, 1, 'SONG', 79),
(4, '2025-06-08 11:00:00', 172, 1, 'SONG', 64),
(4, '2025-06-08 11:03:30', 245, 1, 'SONG', 67),
(5, '2025-06-09 09:00:00', 233, 1, 'SONG', 29),
(5, '2025-06-09 09:04:00', 254, 1, 'SONG', 1),
(6, '2025-06-10 13:00:00', 186, 1, 'SONG', 21),
(6, '2025-06-10 13:03:30', 253, 1, 'SONG', 54),
(8, '2025-06-11 10:00:00', 172, 3, 'SONG', 64),
(8, '2025-06-11 10:03:30', 180, 3, 'SONG', 47),
(9, '2025-06-12 14:00:00', 191, 1, 'SONG', 16),
(9, '2025-06-12 14:04:00', 179, 1, 'SONG', 27),
(12, '2025-06-13 16:00:00', 148, 1, 'SONG', 79),
(12, '2025-06-13 16:02:30', 218, 1, 'SONG', 81),
(15, '2025-06-14 17:00:00', 200, 1, 'SONG', 38),
(15, '2025-06-14 17:03:30', 233, 1, 'SONG', 39);


INSERT INTO PlaybackHistory (UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID) VALUES
(6, '2024-02-10 08:00:00', 2400, 1, 'EPISODE', 1),
(6, '2024-02-10 09:00:00', 2150, 1, 'EPISODE', 2),
(17, '2024-02-11 10:00:00', 2400, 3, 'EPISODE', 1),
(17, '2024-02-11 11:00:00', 3600, 3, 'EPISODE', 28),
(22, '2024-02-11 12:00:00', 2400, 3, 'EPISODE', 1),
(22, '2024-02-11 13:00:00', 3900, 3, 'EPISODE', 29),
(3, '2024-02-12 14:00:00', 10800, 1, 'EPISODE', 11),
(3, '2024-02-12 17:00:00', 2850, 1, 'EPISODE', 34),
(7, '2024-02-13 09:00:00', 2700, 4, 'EPISODE', 37),
(7, '2024-02-13 10:00:00', 10800, 4, 'EPISODE', 11),
(10, '2024-02-14 11:00:00', 2850, 1, 'EPISODE', 34),
(10, '2024-02-14 12:00:00', 10800, 1, 'EPISODE', 11),
(13, '2024-02-14 15:00:00', 10800, 1, 'EPISODE', 11),
(13, '2024-02-14 18:00:00', 2850, 1, 'EPISODE', 34),
(15, '2024-02-15 10:00:00', 2850, 1, 'EPISODE', 34),
(15, '2024-02-15 11:00:00', 2400, 1, 'EPISODE', 25),
(19, '2024-02-15 14:00:00', 10800, 1, 'EPISODE', 11),
(19, '2024-02-15 17:00:00', 2850, 1, 'EPISODE', 34),
(24, '2024-02-16 09:00:00', 10800, 1, 'EPISODE', 11),
(24, '2024-02-16 12:00:00', 9200, 1, 'EPISODE', 12),
(5, '2024-02-17 11:00:00', 7200, 1, 'EPISODE', 19),
(5, '2024-02-17 13:00:00', 7500, 1, 'EPISODE', 21),
(21, '2024-02-18 10:00:00', 5400, 3, 'EPISODE', 6),
(21, '2024-02-18 12:00:00', 7200, 3, 'EPISODE', 19),
(25, '2024-02-19 14:00:00', 7200, 1, 'EPISODE', 19),
(7, '2024-03-14 09:00:00', 2700, 1, 'EPISODE', 37),
(7, '2024-03-14 10:00:00', 2400, 1, 'EPISODE', 25),
(8, '2024-03-15 08:00:00', 10800, 1, 'EPISODE', 11),
(8, '2024-03-15 11:30:00', 2400, 1, 'EPISODE', 25),
(9, '2024-03-16 10:00:00', 2400, 1, 'EPISODE', 25),
(9, '2024-03-16 11:00:00', 2850, 1, 'EPISODE', 34),
(10, '2024-03-17 09:00:00', 2850, 1, 'EPISODE', 34),
(10, '2024-03-17 10:00:00', 10800, 1, 'EPISODE', 11),
(11, '2024-03-18 12:00:00', 5400, 3, 'EPISODE', 6),
(11, '2024-03-18 14:00:00', 1800, 3, 'EPISODE', 31),
(12, '2024-03-19 11:00:00', 5400, 1, 'EPISODE', 6),
(12, '2024-03-19 13:00:00', 3600, 1, 'EPISODE', 16),
(13, '2024-03-20 15:00:00', 10800, 1, 'EPISODE', 11),
(13, '2024-03-20 18:30:00', 2850, 1, 'EPISODE', 34),
(14, '2024-03-21 10:00:00', 5400, 1, 'EPISODE', 6),
(14, '2024-03-21 12:00:00', 7200, 1, 'EPISODE', 19),
(15, '2024-03-22 09:00:00', 2850, 1, 'EPISODE', 34),
(15, '2024-03-22 10:00:00', 2400, 1, 'EPISODE', 25),
(16, '2024-03-23 08:00:00', 3600, 1, 'EPISODE', 16),
(16, '2024-03-23 09:30:00', 5400, 1, 'EPISODE', 6),
(1, '2024-03-24 10:00:00', 10800, 2, 'EPISODE', 11),
(2, '2024-03-25 11:00:00', 10800, 1, 'EPISODE', 11),
(3, '2024-03-26 09:00:00', 10800, 3, 'EPISODE', 11),
(4, '2024-03-27 10:00:00', 5400, 1, 'EPISODE', 6),
(5, '2024-03-28 11:00:00', 5400, 1, 'EPISODE', 6),
(4, '2024-04-11 09:00:00', 5400, 3, 'EPISODE', 7),
(4, '2024-04-11 11:00:00', 3600, 3, 'EPISODE', 16),
(5, '2024-04-12 10:00:00', 5400, 1, 'EPISODE', 7),
(5, '2024-04-12 12:00:00', 7200, 1, 'EPISODE', 19),
(6, '2024-04-13 09:00:00', 2400, 1, 'EPISODE', 1),
(6, '2024-04-13 10:00:00', 2850, 1, 'EPISODE', 34),
(11, '2024-04-14 12:00:00', 5400, 3, 'EPISODE', 7),
(11, '2024-04-14 14:00:00', 1800, 3, 'EPISODE', 31),
(12, '2024-04-15 11:00:00', 5400, 1, 'EPISODE', 7),
(12, '2024-04-15 13:00:00', 4200, 1, 'EPISODE', 17),
(14, '2024-04-16 10:00:00', 5400, 1, 'EPISODE', 7),
(14, '2024-04-16 12:00:00', 6800, 1, 'EPISODE', 20),
(16, '2024-04-17 08:00:00', 3900, 1, 'EPISODE', 18),
(16, '2024-04-17 09:30:00', 5400, 1, 'EPISODE', 7),
(20, '2024-04-18 13:00:00', 1800, 1, 'EPISODE', 31),
(20, '2024-04-18 14:00:00', 6800, 1, 'EPISODE', 20),
(21, '2024-04-19 10:00:00', 5400, 3, 'EPISODE', 7),
(21, '2024-04-19 12:00:00', 7200, 3, 'EPISODE', 19),
(23, '2024-04-20 11:00:00', 3900, 1, 'EPISODE', 18),
(23, '2024-04-20 12:30:00', 5400, 1, 'EPISODE', 7),
(25, '2024-04-21 14:00:00', 7200, 1, 'EPISODE', 19),
(25, '2024-04-21 16:00:00', 2400, 1, 'EPISODE', 25),
(1, '2024-04-22 09:00:00', 5400, 2, 'EPISODE', 22),
(2, '2024-04-23 10:00:00', 2500, 1, 'EPISODE', 26),
(3, '2024-04-24 08:00:00', 2850, 3, 'EPISODE', 34),
(21, '2024-05-10 09:00:00', 5400, 3, 'EPISODE', 7),
(21, '2024-05-10 11:00:00', 7200, 3, 'EPISODE', 19),
(21, '2024-05-10 13:00:00', 3900, 3, 'EPISODE', 18),
(20, '2024-05-11 10:00:00', 1800, 1, 'EPISODE', 31),
(20, '2024-05-11 11:00:00', 7200, 1, 'EPISODE', 19),
(20, '2024-05-11 13:00:00', 7200, 1, 'EPISODE', 6),
(14, '2024-05-12 09:00:00', 5400, 1, 'EPISODE', 7),
(14, '2024-05-12 11:00:00', 7200, 1, 'EPISODE', 19),
(5, '2024-05-13 10:00:00', 5400, 1, 'EPISODE', 7),
(5, '2024-05-13 12:00:00', 7500, 1, 'EPISODE', 21),
(25, '2024-05-14 09:00:00', 7200, 1, 'EPISODE', 19),
(25, '2024-05-14 11:00:00', 2500, 1, 'EPISODE', 26),
(11, '2024-05-15 14:00:00', 5400, 3, 'EPISODE', 7),
(11, '2024-05-15 16:00:00', 2100, 3, 'EPISODE', 32),
(12, '2024-05-16 11:00:00', 5400, 1, 'EPISODE', 7),
(12, '2024-05-16 13:00:00', 3600, 1, 'EPISODE', 16),
(4, '2024-05-17 10:00:00', 5400, 1, 'EPISODE', 7),
(4, '2024-05-17 12:00:00', 4200, 1, 'EPISODE', 17),
(1, '2024-05-18 09:00:00', 10800, 2, 'EPISODE', 11),
(1, '2024-05-18 12:30:00', 5400, 2, 'EPISODE', 22),
(2, '2024-05-19 11:00:00', 10800, 1, 'EPISODE', 11),
(2, '2024-05-19 14:30:00', 2400, 1, 'EPISODE', 25),
(3, '2024-05-20 09:00:00', 10800, 3, 'EPISODE', 11),
(3, '2024-05-20 12:30:00', 2850, 3, 'EPISODE', 34),
(10, '2024-05-21 11:00:00', 10800, 1, 'EPISODE', 11),
(1, '2024-06-10 08:00:00', 10800, 2, 'EPISODE', 11),
(1, '2024-06-10 11:30:00', 5700, 2, 'EPISODE', 24),
(2, '2024-06-11 09:00:00', 10800, 1, 'EPISODE', 11),
(2, '2024-06-11 12:15:00', 2400, 1, 'EPISODE', 25),
(3, '2024-06-12 10:00:00', 10800, 3, 'EPISODE', 11),
(3, '2024-06-12 13:30:00', 3120, 3, 'EPISODE', 35),
(7, '2024-06-13 14:00:00', 10800, 1, 'EPISODE', 11),
(7, '2024-06-13 17:15:00', 2500, 1, 'EPISODE', 26),
(8, '2024-06-14 11:00:00', 10800, 1, 'EPISODE', 11),
(8, '2024-06-14 14:15:00', 2600, 1, 'EPISODE', 27),
(10, '2024-06-15 09:00:00', 10800, 1, 'EPISODE', 11),
(10, '2024-06-15 12:30:00', 8500, 1, 'EPISODE', 13),
(13, '2024-06-16 16:00:00', 10800, 1, 'EPISODE', 11),
(13, '2024-06-16 19:30:00', 3400, 1, 'EPISODE', 36),
(18, '2024-06-17 10:00:00', 10800, 1, 'EPISODE', 11),
(18, '2024-06-17 13:30:00', 9200, 1, 'EPISODE', 12),
(19, '2024-06-18 11:00:00', 10800, 1, 'EPISODE', 11),
(19, '2024-06-18 14:30:00', 3120, 1, 'EPISODE', 35),
(24, '2024-06-19 15:00:00', 10800, 1, 'EPISODE', 11),
(24, '2024-06-19 18:30:00', 11200, 1, 'EPISODE', 14),
(6, '2024-06-20 08:00:00', 2400, 1, 'EPISODE', 1),
(17, '2024-06-20 10:00:00', 2400, 1, 'EPISODE', 1),
(22, '2024-06-21 11:00:00', 2400, 1, 'EPISODE', 1),
(4, '2024-06-21 14:00:00', 5400, 3, 'EPISODE', 7),
(5, '2024-06-22 10:00:00', 5400, 1, 'EPISODE', 7),
(4, '2024-07-10 09:00:00', 3600, 3, 'EPISODE', 16),
(4, '2024-07-10 10:30:00', 4200, 3, 'EPISODE', 17),
(5, '2024-07-11 11:00:00', 7200, 1, 'EPISODE', 19),
(5, '2024-07-11 13:30:00', 7500, 1, 'EPISODE', 21),
(7, '2024-07-12 14:00:00', 2700, 1, 'EPISODE', 37),
(7, '2024-07-12 15:00:00', 3150, 1, 'EPISODE', 38),
(11, '2024-07-13 12:00:00', 7200, 3, 'EPISODE', 6),
(11, '2024-07-13 14:30:00', 2100, 3, 'EPISODE', 32),
(12, '2024-07-14 10:00:00', 3600, 1, 'EPISODE', 16),
(12, '2024-07-14 11:30:00', 3900, 1, 'EPISODE', 18),
(14, '2024-07-15 09:00:00', 7200, 1, 'EPISODE', 19),
(14, '2024-07-15 11:30:00', 6800, 1, 'EPISODE', 20),
(16, '2024-07-16 08:00:00', 3600, 1, 'EPISODE', 16),
(16, '2024-07-16 09:30:00', 5400, 1, 'EPISODE', 7),
(20, '2024-07-17 13:00:00', 1800, 1, 'EPISODE', 31),
(20, '2024-07-17 14:00:00', 2000, 1, 'EPISODE', 33),
(21, '2024-07-18 10:00:00', 3600, 3, 'EPISODE', 16),
(21, '2024-07-18 11:30:00', 7500, 3, 'EPISODE', 21),
(23, '2024-07-19 11:00:00', 3600, 1, 'EPISODE', 16),
(23, '2024-07-19 12:30:00', 3900, 1, 'EPISODE', 18),
(25, '2024-07-20 14:00:00', 7200, 1, 'EPISODE', 19),
(25, '2024-07-20 16:30:00', 7500, 1, 'EPISODE', 21),
(1, '2024-07-21 09:00:00', 6000, 2, 'EPISODE', 23),
(2, '2024-07-22 10:00:00', 2600, 1, 'EPISODE', 27),
(3, '2024-07-23 08:00:00', 2850, 3, 'EPISODE', 34),
(6, '2024-08-13 08:00:00', 2400, 1, 'EPISODE', 1),
(6, '2024-08-13 09:30:00', 2850, 1, 'EPISODE', 34),
(17, '2024-08-14 10:00:00', 2400, 1, 'EPISODE', 1),
(17, '2024-08-14 11:30:00', 1800, 1, 'EPISODE', 31),
(22, '2024-08-15 12:00:00', 2400, 1, 'EPISODE', 1),
(22, '2024-08-15 13:30:00', 2100, 1, 'EPISODE', 32),
(3, '2024-08-16 14:00:00', 10800, 1, 'EPISODE', 11),
(3, '2024-08-16 17:30:00', 2850, 1, 'EPISODE', 34),
(1, '2024-08-17 09:00:00', 7200, 2, 'EPISODE', 6),
(1, '2024-08-17 11:30:00', 5400, 2, 'EPISODE', 22),
(2, '2024-08-18 10:00:00', 5400, 1, 'EPISODE', 7),
(2, '2024-08-18 12:30:00', 2500, 1, 'EPISODE', 26),
(4, '2024-08-19 11:00:00', 5400, 3, 'EPISODE', 6),
(4, '2024-08-19 13:00:00', 3600, 3, 'EPISODE', 16),
(5, '2024-08-20 12:00:00', 7200, 1, 'EPISODE', 19),
(5, '2024-08-20 14:30:00', 7500, 1, 'EPISODE', 21),
(11, '2024-08-21 15:00:00', 5400, 3, 'EPISODE', 6),
(11, '2024-08-21 17:00:00', 1800, 3, 'EPISODE', 31),
(12, '2024-08-22 09:00:00', 5400, 1, 'EPISODE', 7),
(12, '2024-08-22 11:30:00', 4200, 1, 'EPISODE', 17),
(14, '2024-08-23 10:00:00', 7200, 1, 'EPISODE', 19),
(14, '2024-08-23 12:30:00', 6800, 1, 'EPISODE', 20),
(19, '2024-08-24 14:00:00', 10800, 1, 'EPISODE', 11),
(19, '2024-08-24 17:30:00', 2850, 1, 'EPISODE', 34),
(21, '2024-08-25 11:00:00', 5400, 3, 'EPISODE', 6),
(1, '2024-09-10 08:00:00', 5400, 2, 'EPISODE', 22),
(2, '2024-09-11 09:00:00', 2400, 1, 'EPISODE', 25),
(3, '2024-09-12 10:00:00', 2850, 3, 'EPISODE', 34),
(4, '2024-09-13 11:00:00', 7200, 1, 'EPISODE', 6),
(5, '2024-09-14 12:00:00', 7200, 1, 'EPISODE', 19),
(6, '2024-09-15 09:00:00', 2400, 1, 'EPISODE', 1),
(7, '2024-09-16 10:00:00', 2700, 1, 'EPISODE', 37),
(8, '2024-09-17 11:00:00', 2500, 1, 'EPISODE', 26),
(9, '2024-09-18 12:00:00', 3120, 1, 'EPISODE', 35),
(10, '2024-09-19 13:00:00', 10800, 1, 'EPISODE', 11),
(11, '2024-09-20 14:00:00', 1800, 3, 'EPISODE', 31),
(12, '2024-09-21 15:00:00', 3600, 1, 'EPISODE', 16),
(13, '2024-09-22 16:00:00', 9200, 1, 'EPISODE', 12),
(14, '2024-09-23 17:00:00', 5400, 1, 'EPISODE', 7),
(15, '2024-09-24 18:00:00', 2600, 1, 'EPISODE', 27),
(16, '2024-09-25 19:00:00', 6100, 1, 'EPISODE', 8),
(17, '2024-09-26 10:00:00', 3600, 1, 'EPISODE', 28),
(18, '2024-09-27 11:00:00', 8500, 1, 'EPISODE', 13),
(19, '2024-09-28 12:00:00', 3400, 1, 'EPISODE', 36),
(20, '2024-09-29 13:00:00', 6800, 1, 'EPISODE', 20),
(21, '2024-09-30 14:00:00', 4200, 1, 'EPISODE', 17),
(22, '2024-09-05 15:00:00', 2100, 1, 'EPISODE', 32),
(23, '2024-09-06 16:00:00', 6800, 1, 'EPISODE', 9),
(24, '2024-09-07 17:00:00', 2850, 1, 'EPISODE', 34),
(25, '2024-09-08 18:00:00', 7500, 1, 'EPISODE', 21),
(3, '2024-10-20 08:00:00', 10800, 1, 'EPISODE', 11),
(3, '2024-10-20 11:30:00', 9200, 1, 'EPISODE', 12),
(5, '2024-10-21 09:00:00', 7200, 1, 'EPISODE', 19),
(5, '2024-10-21 11:30:00', 6800, 1, 'EPISODE', 20),
(7, '2024-10-22 10:00:00', 10800, 1, 'EPISODE', 11),
(7, '2024-10-22 13:30:00', 2400, 1, 'EPISODE', 25),
(10, '2024-10-23 11:00:00', 2850, 1, 'EPISODE', 34),
(10, '2024-10-23 12:00:00', 3120, 1, 'EPISODE', 35),
(13, '2024-10-24 12:00:00', 10800, 1, 'EPISODE', 11),
(13, '2024-10-24 15:30:00', 2850, 1, 'EPISODE', 34),
(15, '2024-10-25 09:00:00', 2850, 1, 'EPISODE', 34),
(15, '2024-10-25 10:00:00', 3120, 1, 'EPISODE', 35),
(19, '2024-10-26 14:00:00', 10800, 1, 'EPISODE', 11),
(19, '2024-10-26 17:30:00', 2850, 1, 'EPISODE', 34),
(24, '2024-10-27 15:00:00', 10800, 1, 'EPISODE', 11),
(24, '2024-10-27 18:30:00', 2850, 1, 'EPISODE', 34),
(6, '2024-10-28 08:00:00', 2400, 1, 'EPISODE', 1),
(6, '2024-10-28 09:00:00', 2150, 1, 'EPISODE', 2),
(17, '2024-10-29 10:00:00', 2400, 1, 'EPISODE', 1),
(17, '2024-10-29 11:00:00', 3600, 1, 'EPISODE', 28),
(22, '2024-10-30 11:00:00', 2400, 1, 'EPISODE', 1),
(22, '2024-10-30 12:00:00', 1800, 1, 'EPISODE', 31),
(1, '2024-10-31 09:00:00', 5400, 2, 'EPISODE', 22),
(2, '2024-10-31 11:00:00', 2400, 1, 'EPISODE', 25),
(4, '2024-10-31 13:00:00', 5400, 3, 'EPISODE', 6),
(2, '2024-11-20 09:00:00', 5400, 3, 'EPISODE', 7),
(2, '2024-11-20 10:30:00', 6100, 3, 'EPISODE', 8),
(4, '2024-11-21 11:00:00', 5400, 1, 'EPISODE', 7),
(4, '2024-11-21 12:30:00', 4200, 1, 'EPISODE', 17),
(5, '2024-11-22 13:00:00', 7200, 1, 'EPISODE', 19),
(5, '2024-11-22 15:00:00', 6800, 1, 'EPISODE', 20),
(11, '2024-11-23 10:00:00', 5400, 3, 'EPISODE', 7),
(11, '2024-11-23 11:30:00', 5900, 3, 'EPISODE', 10),
(12, '2024-11-24 14:00:00', 5400, 1, 'EPISODE', 7),
(12, '2024-11-24 15:30:00', 3900, 1, 'EPISODE', 18),
(14, '2024-11-25 09:00:00', 5400, 1, 'EPISODE', 7),
(14, '2024-11-25 10:30:00', 7500, 1, 'EPISODE', 21),
(21, '2024-11-26 12:00:00', 5400, 3, 'EPISODE', 7),
(21, '2024-11-26 13:30:00', 6800, 3, 'EPISODE', 9),
(1, '2024-11-27 08:00:00', 6000, 2, 'EPISODE', 23),
(3, '2024-11-27 10:00:00', 10800, 3, 'EPISODE', 11),
(6, '2024-11-28 09:00:00', 2400, 1, 'EPISODE', 1),
(6, '2024-11-28 10:00:00', 2300, 1, 'EPISODE', 4),
(17, '2024-11-29 11:00:00', 2400, 1, 'EPISODE', 1),
(17, '2024-11-29 12:00:00', 4200, 1, 'EPISODE', 30),
(22, '2024-11-30 13:00:00', 2400, 1, 'EPISODE', 1),
(22, '2024-11-30 14:00:00', 2000, 1, 'EPISODE', 33),
(7, '2024-11-15 15:00:00', 2700, 1, 'EPISODE', 37),
(8, '2024-11-16 16:00:00', 10800, 1, 'EPISODE', 11),
(10, '2024-11-17 09:00:00', 2850, 1, 'EPISODE', 34),
(2, '2024-11-20 09:00:00', 5400, 3, 'EPISODE', 7),
(2, '2024-11-20 10:30:00', 6100, 3, 'EPISODE', 8),
(4, '2024-11-21 11:00:00', 5400, 1, 'EPISODE', 7),
(4, '2024-11-21 12:30:00', 4200, 1, 'EPISODE', 17),
(5, '2024-11-22 13:00:00', 7200, 1, 'EPISODE', 19),
(5, '2024-11-22 15:00:00', 6800, 1, 'EPISODE', 20),
(11, '2024-11-23 10:00:00', 5400, 3, 'EPISODE', 7),
(11, '2024-11-23 11:30:00', 5900, 3, 'EPISODE', 10),
(12, '2024-11-24 14:00:00', 5400, 1, 'EPISODE', 7),
(12, '2024-11-24 15:30:00', 3900, 1, 'EPISODE', 18),
(14, '2024-11-25 09:00:00', 5400, 1, 'EPISODE', 7),
(14, '2024-11-25 10:30:00', 7500, 1, 'EPISODE', 21),
(21, '2024-11-26 12:00:00', 5400, 3, 'EPISODE', 7),
(21, '2024-11-26 13:30:00', 6800, 3, 'EPISODE', 9),
(1, '2024-11-27 08:00:00', 6000, 2, 'EPISODE', 23),
(3, '2024-11-27 10:00:00', 10800, 3, 'EPISODE', 11),
(6, '2024-11-28 09:00:00', 2400, 1, 'EPISODE', 1),
(6, '2024-11-28 10:00:00', 2300, 1, 'EPISODE', 4),
(17, '2024-11-29 11:00:00', 2400, 1, 'EPISODE', 1),
(17, '2024-11-29 12:00:00', 4200, 1, 'EPISODE', 30),
(22, '2024-11-30 13:00:00', 2400, 1, 'EPISODE', 1),
(22, '2024-11-30 14:00:00', 2000, 1, 'EPISODE', 33),
(7, '2024-11-15 15:00:00', 2700, 1, 'EPISODE', 37),
(8, '2024-11-16 16:00:00', 10800, 1, 'EPISODE', 11),
(10, '2024-11-17 09:00:00', 2850, 1, 'EPISODE', 34),
(2, '2025-01-16 09:00:00', 5400, 3, 'EPISODE', 7),
(2, '2025-01-16 10:30:00', 6800, 3, 'EPISODE', 9),
(4, '2025-01-17 11:00:00', 7200, 1, 'EPISODE', 6),
(4, '2025-01-17 13:00:00', 3600, 1, 'EPISODE', 16),
(5, '2025-01-18 10:00:00', 7200, 1, 'EPISODE', 19),
(5, '2025-01-18 12:00:00', 6800, 1, 'EPISODE', 20),
(11, '2025-01-19 14:00:00', 5400, 3, 'EPISODE', 7),
(11, '2025-01-19 15:30:00', 1800, 3, 'EPISODE', 31),
(12, '2025-01-20 11:00:00', 5400, 1, 'EPISODE', 7),
(12, '2025-01-20 12:30:00', 4200, 1, 'EPISODE', 17),
(14, '2025-01-21 09:00:00', 5400, 1, 'EPISODE', 7),
(14, '2025-01-21 10:30:00', 7500, 1, 'EPISODE', 21),
(16, '2025-01-22 08:00:00', 5400, 1, 'EPISODE', 6),
(16, '2025-01-22 10:00:00', 5400, 1, 'EPISODE', 7),
(1, '2025-01-23 09:00:00', 6000, 2, 'EPISODE', 23),
(3, '2025-01-23 11:00:00', 10800, 3, 'EPISODE', 11),
(6, '2025-01-24 09:00:00', 2400, 1, 'EPISODE', 1),
(6, '2025-01-24 10:00:00', 2150, 1, 'EPISODE', 2),
(17, '2025-01-25 10:00:00', 2400, 1, 'EPISODE', 1),
(22, '2025-01-26 11:00:00', 2400, 1, 'EPISODE', 1),
(22, '2025-01-26 12:00:00', 1800, 1, 'EPISODE', 31),
(7, '2025-01-27 15:00:00', 10800, 1, 'EPISODE', 11),
(8, '2025-01-28 16:00:00', 10800, 1, 'EPISODE', 11),
(10, '2025-01-29 09:00:00', 2850, 1, 'EPISODE', 34),
(10, '2025-02-24 09:00:00', 2850, 1, 'EPISODE', 34),
(10, '2025-02-24 10:00:00', 3120, 1, 'EPISODE', 35),
(13, '2025-02-25 12:00:00', 10800, 1, 'EPISODE', 11),
(13, '2025-02-25 15:30:00', 3400, 1, 'EPISODE', 36),
(15, '2025-02-26 10:00:00', 2850, 1, 'EPISODE', 34),
(15, '2025-02-26 11:00:00', 3120, 1, 'EPISODE', 35),
(19, '2025-02-27 14:00:00', 10800, 1, 'EPISODE', 11),
(19, '2025-02-27 17:30:00', 3120, 1, 'EPISODE', 35),
(24, '2025-02-28 15:00:00', 10800, 1, 'EPISODE', 11),
(24, '2025-02-28 18:30:00', 7800, 1, 'EPISODE', 15),
(11, '2025-03-01 11:00:00', 5400, 3, 'EPISODE', 6),
(11, '2025-03-01 13:00:00', 1800, 3, 'EPISODE', 31),
(1, '2025-03-02 09:00:00', 7200, 2, 'EPISODE', 6),
(1, '2025-03-02 11:30:00', 5400, 2, 'EPISODE', 22),
(2, '2025-03-03 10:00:00', 10800, 1, 'EPISODE', 11),
(2, '2025-03-03 13:30:00', 2500, 1, 'EPISODE', 26),
(4, '2025-03-04 11:00:00', 5400, 3, 'EPISODE', 6),
(4, '2025-03-04 13:00:00', 3600, 3, 'EPISODE', 16),
(5, '2025-03-05 12:00:00', 7200, 1, 'EPISODE', 19),
(5, '2025-03-05 14:30:00', 6800, 1, 'EPISODE', 20),
(6, '2025-03-06 08:00:00', 2400, 1, 'EPISODE', 1),
(6, '2025-03-06 09:00:00', 2150, 1, 'EPISODE', 2),
(17, '2025-03-07 10:00:00', 2400, 1, 'EPISODE', 1),
(17, '2025-03-07 11:00:00', 3900, 1, 'EPISODE', 18),
(22, '2025-03-08 11:00:00', 2400, 1, 'EPISODE', 1),
(1, '2025-08-01 09:00:00', 5400, 2, 'EPISODE', 22),
(1, '2025-08-01 11:00:00', 6000, 2, 'EPISODE', 23),
(2, '2025-08-02 10:00:00', 5400, 1, 'EPISODE', 7),
(2, '2025-08-02 12:00:00', 6100, 1, 'EPISODE', 8),
(3, '2025-08-03 08:00:00', 10800, 1, 'EPISODE', 11),
(3, '2025-08-03 11:30:00', 9200, 1, 'EPISODE', 12),
(4, '2025-08-04 10:00:00', 5400, 1, 'EPISODE', 7),
(4, '2025-08-04 12:00:00', 4200, 1, 'EPISODE', 17),
(5, '2025-08-05 11:00:00', 7200, 1, 'EPISODE', 19),
(5, '2025-08-05 13:30:00', 6800, 1, 'EPISODE', 20),
(6, '2025-08-06 09:00:00', 2400, 1, 'EPISODE', 1),
(6, '2025-08-06 10:00:00', 2150, 1, 'EPISODE', 2),
(7, '2025-08-07 14:00:00', 2700, 1, 'EPISODE', 37),
(7, '2025-08-07 15:00:00', 3150, 1, 'EPISODE', 38),
(11, '2025-08-08 12:00:00', 5400, 3, 'EPISODE', 6),
(11, '2025-08-08 14:00:00', 1800, 3, 'EPISODE', 31),
(12, '2025-08-09 11:00:00', 5400, 1, 'EPISODE', 7),
(12, '2025-08-09 13:00:00', 3600, 1, 'EPISODE', 16),
(14, '2025-08-10 09:00:00', 5400, 1, 'EPISODE', 7),
(14, '2025-08-10 10:30:00', 7500, 1, 'EPISODE', 21),
(17, '2025-08-11 10:00:00', 2400, 1, 'EPISODE', 1),
(17, '2025-08-11 11:00:00', 3600, 1, 'EPISODE', 28),
(20, '2025-08-12 13:00:00', 1800, 1, 'EPISODE', 31),
(21, '2025-08-13 10:00:00', 5400, 3, 'EPISODE', 6),
(22, '2025-08-14 11:00:00', 2400, 1, 'EPISODE', 1),
(1, '2025-10-01 08:00:00', 10800, 2, 'EPISODE', 11),
(1, '2025-10-01 11:30:00', 5400, 2, 'EPISODE', 22),
(2, '2025-10-02 09:00:00', 10800, 1, 'EPISODE', 11),
(2, '2025-10-02 12:30:00', 2400, 1, 'EPISODE', 25),
(3, '2025-10-03 10:00:00', 10800, 3, 'EPISODE', 11),
(3, '2025-10-03 13:30:00', 2850, 3, 'EPISODE', 34),
(4, '2025-10-04 11:00:00', 5400, 3, 'EPISODE', 6),
(4, '2025-10-04 13:00:00', 3600, 3, 'EPISODE', 16),
(5, '2025-10-05 12:00:00', 7200, 1, 'EPISODE', 19),
(5, '2025-10-05 14:30:00', 6800, 1, 'EPISODE', 20),
(6, '2025-10-06 09:00:00', 2400, 1, 'EPISODE', 1),
(6, '2025-10-06 10:00:00', 2850, 1, 'EPISODE', 34),
(11, '2025-10-07 14:00:00', 5400, 3, 'EPISODE', 6),
(11, '2025-10-07 16:00:00', 1800, 3, 'EPISODE', 31),
(12, '2025-10-08 11:00:00', 5400, 1, 'EPISODE', 7),
(12, '2025-10-08 13:00:00', 4200, 1, 'EPISODE', 17),
(14, '2025-10-09 10:00:00', 5400, 1, 'EPISODE', 7),
(14, '2025-10-09 12:00:00', 7200, 1, 'EPISODE', 19),
(17, '2025-10-10 09:00:00', 2400, 1, 'EPISODE', 1),
(17, '2025-10-10 10:00:00', 3600, 1, 'EPISODE', 28),
(20, '2025-10-11 13:00:00', 1800, 1, 'EPISODE', 31),
(21, '2025-10-12 10:00:00', 5400, 3, 'EPISODE', 6),
(22, '2025-10-13 11:00:00', 2400, 1, 'EPISODE', 1),
(24, '2025-10-14 15:00:00', 10800, 1, 'EPISODE', 11),
(25, '2025-10-15 14:00:00', 7200, 1, 'EPISODE', 19),
(1, '2025-12-10 09:00:00', 5400, 2, 'EPISODE', 22),
(2, '2025-12-11 10:00:00', 5400, 1, 'EPISODE', 7),
(3, '2025-12-12 08:00:00', 10800, 1, 'EPISODE', 11),
(4, '2025-12-13 10:00:00', 5400, 1, 'EPISODE', 7),
(5, '2025-12-14 11:00:00', 7200, 1, 'EPISODE', 19),
(6, '2025-12-15 09:00:00', 2400, 1, 'EPISODE', 1),
(11, '2025-12-16 12:00:00', 5400, 3, 'EPISODE', 6),
(12, '2025-12-17 11:00:00', 5400, 1, 'EPISODE', 7),
(14, '2025-12-18 09:00:00', 5400, 1, 'EPISODE', 7),
(17, '2025-12-19 10:00:00', 2400, 1, 'EPISODE', 1),
(21, '2025-12-20 10:00:00', 5400, 3, 'EPISODE', 6),
(22, '2025-12-21 11:00:00', 2400, 1, 'EPISODE', 1),
(25, '2025-12-22 14:00:00', 7200, 1, 'EPISODE', 19),
(7, '2025-01-15 09:00:00', 10800, 1, 'EPISODE', 11),
(8, '2025-01-16 08:00:00', 10800, 1, 'EPISODE', 11),
(10, '2025-01-17 11:00:00', 2850, 1, 'EPISODE', 34),
(13, '2025-01-18 12:00:00', 10800, 1, 'EPISODE', 11),
(15, '2025-01-19 10:00:00', 2850, 1, 'EPISODE', 34),
(16, '2025-01-20 08:00:00', 3600, 1, 'EPISODE', 16),
(19, '2025-01-21 11:00:00', 2850, 1, 'EPISODE', 34),
(20, '2025-01-22 13:00:00', 1800, 1, 'EPISODE', 31),
(23, '2025-12-23 11:00:00', 3600, 1, 'EPISODE', 16),
(24, '2025-12-24 15:00:00', 10800, 1, 'EPISODE', 11),
(9, '2025-12-25 10:00:00', 2400, 1, 'EPISODE', 25),
(1, '2025-12-26 09:00:00', 6000, 2, 'EPISODE', 23),
(1, '2025-02-21 09:00:00', 5400, 2, 'EPISODE', 22),
(2, '2025-02-21 11:00:00', 5400, 1, 'EPISODE', 7),
(3, '2025-02-22 08:00:00', 10800, 1, 'EPISODE', 11),
(4, '2025-02-22 10:00:00', 5400, 1, 'EPISODE', 7),
(5, '2025-02-23 11:00:00', 7200, 1, 'EPISODE', 19),
(6, '2025-02-23 13:00:00', 2400, 1, 'EPISODE', 1),
(11, '2025-02-24 12:00:00', 5400, 3, 'EPISODE', 6),
(12, '2025-02-24 14:00:00', 5400, 1, 'EPISODE', 7),
(14, '2025-02-25 09:00:00', 5400, 1, 'EPISODE', 7),
(17, '2025-02-25 10:30:00', 2400, 1, 'EPISODE', 1),
(21, '2025-02-26 12:00:00', 5400, 3, 'EPISODE', 6),
(22, '2025-02-26 13:30:00', 2400, 1, 'EPISODE', 1),
(25, '2025-02-27 14:00:00', 7200, 1, 'EPISODE', 19),
(7, '2025-02-27 16:30:00', 10800, 1, 'EPISODE', 11),
(8, '2025-02-28 08:00:00', 10800, 1, 'EPISODE', 11),
(10, '2025-02-28 11:00:00', 2850, 1, 'EPISODE', 34),
(13, '2025-02-28 13:00:00', 10800, 1, 'EPISODE', 11),
(15, '2025-02-28 15:00:00', 2850, 1, 'EPISODE', 34),
(16, '2025-02-28 17:00:00', 3600, 1, 'EPISODE', 16),
(19, '2025-02-28 19:00:00', 2850, 1, 'EPISODE', 34),
(24, '2025-02-28 21:00:00', 10800, 1, 'EPISODE', 11),
(9, '2025-02-21 13:00:00', 2400, 1, 'EPISODE', 25),
(18, '2025-02-22 13:00:00', 2500, 1, 'EPISODE', 26),
(20, '2025-02-23 15:00:00', 1800, 1, 'EPISODE', 31),
(23, '2025-02-24 16:00:00', 3600, 1, 'EPISODE', 16),
(1, '2025-04-11 09:00:00', 5400, 2, 'EPISODE', 22),
(2, '2025-04-12 10:00:00', 5400, 1, 'EPISODE', 7),
(3, '2025-04-13 08:00:00', 10800, 1, 'EPISODE', 11),
(4, '2025-04-14 10:00:00', 5400, 1, 'EPISODE', 7),
(5, '2025-04-15 11:00:00', 7200, 1, 'EPISODE', 19),
(6, '2025-04-16 09:00:00', 2400, 1, 'EPISODE', 1),
(7, '2025-04-17 14:00:00', 10800, 1, 'EPISODE', 11),
(8, '2025-04-18 08:00:00', 10800, 1, 'EPISODE', 11),
(10, '2025-04-19 11:00:00', 2850, 1, 'EPISODE', 34),
(11, '2025-04-20 12:00:00', 5400, 3, 'EPISODE', 6),
(12, '2025-04-21 14:00:00', 5400, 1, 'EPISODE', 7),
(13, '2025-04-22 13:00:00', 10800, 1, 'EPISODE', 11),
(14, '2025-04-23 09:00:00', 5400, 1, 'EPISODE', 7),
(15, '2025-04-24 15:00:00', 2850, 1, 'EPISODE', 34),
(16, '2025-04-25 17:00:00', 3600, 1, 'EPISODE', 16),
(17, '2025-04-26 10:30:00', 2400, 1, 'EPISODE', 1),
(18, '2025-04-27 13:00:00', 2500, 1, 'EPISODE', 26),
(19, '2025-04-28 19:00:00', 2850, 1, 'EPISODE', 34),
(20, '2025-04-29 15:00:00', 1800, 1, 'EPISODE', 31),
(21, '2025-04-30 12:00:00', 5400, 3, 'EPISODE', 6),
(22, '2025-04-01 13:30:00', 2400, 1, 'EPISODE', 1),
(23, '2025-04-02 16:00:00', 3600, 1, 'EPISODE', 16),
(24, '2025-04-03 21:00:00', 10800, 1, 'EPISODE', 11),
(25, '2025-04-04 14:00:00', 7200, 1, 'EPISODE', 19),
(9, '2025-04-05 13:00:00', 2400, 1, 'EPISODE', 25),
(3, '2025-05-20 08:00:00', 10800, 1, 'EPISODE', 11),
(3, '2025-05-20 11:30:00', 2400, 1, 'EPISODE', 25),
(5, '2025-05-21 09:00:00', 7200, 1, 'EPISODE', 19),
(5, '2025-05-21 11:30:00', 7500, 1, 'EPISODE', 21),
(7, '2025-05-22 10:00:00', 10800, 1, 'EPISODE', 11),
(7, '2025-05-22 13:30:00', 2700, 1, 'EPISODE', 37),
(11, '2025-05-23 11:00:00', 5400, 3, 'EPISODE', 6),
(11, '2025-05-23 13:00:00', 1800, 3, 'EPISODE', 31),
(13, '2025-05-24 12:00:00', 10800, 1, 'EPISODE', 11),
(13, '2025-05-24 15:30:00', 2850, 1, 'EPISODE', 34),
(15, '2025-05-25 09:00:00', 2850, 1, 'EPISODE', 34),
(15, '2025-05-25 10:00:00', 3120, 1, 'EPISODE', 35),
(19, '2025-05-26 14:00:00', 10800, 1, 'EPISODE', 11),
(19, '2025-05-26 17:30:00', 3120, 1, 'EPISODE', 35),
(24, '2025-05-27 15:00:00', 10800, 1, 'EPISODE', 11),
(24, '2025-05-27 18:30:00', 2400, 1, 'EPISODE', 25),
(6, '2025-05-28 08:00:00', 2400, 1, 'EPISODE', 1),
(6, '2025-05-28 09:00:00', 2150, 1, 'EPISODE', 2),
(17, '2025-05-29 10:00:00', 2400, 1, 'EPISODE', 1),
(17, '2025-05-29 11:00:00', 4200, 1, 'EPISODE', 17),
(22, '2025-05-30 11:00:00', 2400, 1, 'EPISODE', 1),
(22, '2025-05-30 12:00:00', 1800, 1, 'EPISODE', 31),
(1, '2025-05-31 09:00:00', 6000, 2, 'EPISODE', 23),
(2, '2025-06-01 11:00:00', 5400, 1, 'EPISODE', 7),
(4, '2025-06-01 13:00:00', 3600, 3, 'EPISODE', 16);


INSERT INTO PlaybackHistory (UserID, PlaybackDate, DurationPlayedSeconds, DeviceTypeID, MediaType, MediaID) VALUES
(7, '2024-02-01 13:59:00', 30, 1, 'AD', 5),
(13, '2024-02-01 14:59:00', 20, 1, 'AD', 12),
(11, '2024-02-02 09:59:00', 30, 3, 'AD', 9),
(19, '2024-02-02 17:59:00', 60, 1, 'AD', 8),
(24, '2024-02-04 10:59:00', 30, 1, 'AD', 11),
(25, '2024-02-04 14:59:00', 45, 1, 'AD', 14),
(8, '2024-02-06 07:59:00', 30, 1, 'AD', 13),
(10, '2024-02-06 15:59:00', 30, 1, 'AD', 7),
(8, '2024-03-15 07:59:00', 15, 1, 'AD', 3),
(9, '2024-03-16 09:59:00', 30, 1, 'AD', 9),
(10, '2024-03-17 08:59:00', 60, 1, 'AD', 8),
(11, '2024-03-18 11:59:00', 30, 3, 'AD', 11),
(12, '2024-03-19 10:59:00', 30, 1, 'AD', 5),
(13, '2024-03-20 14:59:00', 20, 1, 'AD', 4),
(14, '2024-03-21 09:59:00', 45, 1, 'AD', 14),
(15, '2024-03-22 08:59:00', 30, 1, 'AD', 1),
(16, '2024-03-23 07:59:00', 15, 1, 'AD', 15),
(7, '2024-04-01 09:59:00', 30, 1, 'AD', 9),
(8, '2024-04-01 10:59:00', 45, 1, 'AD', 10),
(11, '2024-04-02 13:59:00', 30, 3, 'AD', 5),
(13, '2024-04-03 15:59:00', 30, 1, 'AD', 13),
(15, '2024-04-03 17:59:00', 45, 1, 'AD', 14),
(19, '2024-04-04 08:59:00', 30, 1, 'AD', 1),
(21, '2024-04-04 10:59:00', 60, 3, 'AD', 2),
(23, '2024-04-05 12:59:00', 15, 1, 'AD', 3),
(25, '2024-04-05 14:59:00', 20, 1, 'AD', 4),
(15, '2024-05-01 08:59:00', 15, 1, 'AD', 3),
(14, '2024-05-01 09:59:00', 30, 1, 'AD', 5),
(16, '2024-05-02 10:59:00', 30, 1, 'AD', 7),
(18, '2024-05-02 13:59:00', 30, 3, 'AD', 13),
(20, '2024-05-03 15:59:00', 20, 3, 'AD', 12),
(25, '2024-05-03 17:59:00', 15, 1, 'AD', 15),
(21, '2024-05-10 08:59:00', 30, 3, 'AD', 9),
(11, '2024-05-15 13:59:00', 45, 3, 'AD', 10),
(13, '2024-05-06 16:59:00', 30, 1, 'AD', 1),
(7, '2024-04-30 20:00:00', 60, 1, 'AD', 2),
(2, '2024-06-01 08:59:00', 30, 1, 'AD', 1),
(4, '2024-06-02 11:59:00', 45, 1, 'AD', 6),
(7, '2024-06-03 09:59:00', 15, 1, 'AD', 3),
(8, '2024-06-03 12:59:00', 20, 3, 'AD', 4),
(10, '2024-06-04 15:59:00', 30, 1, 'AD', 5),
(13, '2024-06-05 19:59:00', 60, 1, 'AD', 2),
(19, '2024-06-06 08:59:00', 30, 1, 'AD', 7),
(22, '2024-06-21 10:59:00', 15, 1, 'AD', 15),
(24, '2024-06-07 15:59:00', 30, 1, 'AD', 11),
(17, '2024-06-05 21:59:00', 20, 1, 'AD', 12),
(6, '2024-07-01 09:59:00', 30, 1, 'AD', 5),
(7, '2024-07-01 13:59:00', 45, 1, 'AD', 6),
(8, '2024-07-02 08:59:00', 20, 1, 'AD', 4),
(9, '2024-07-02 11:59:00', 30, 1, 'AD', 7),
(10, '2024-07-03 14:59:00', 60, 1, 'AD', 8),
(13, '2024-07-03 17:59:00', 30, 1, 'AD', 13),
(14, '2024-07-04 09:59:00', 30, 1, 'AD', 1),
(15, '2024-07-04 13:59:00', 15, 1, 'AD', 3),
(16, '2024-07-05 15:59:00', 20, 1, 'AD', 12),
(18, '2024-07-05 17:59:00', 30, 3, 'AD', 9),
(1, '2024-08-05 17:59:00', 30, 1, 'AD', 11),
(2, '2024-08-06 08:59:00', 30, 1, 'AD', 1),
(11, '2024-08-01 09:59:00', 45, 3, 'AD', 10),
(15, '2024-08-01 11:59:00', 15, 1, 'AD', 3),
(22, '2024-08-07 09:59:00', 15, 3, 'AD', 15),
(25, '2024-08-02 13:59:00', 30, 1, 'AD', 19),
(7, '2024-08-03 08:59:00', 30, 4, 'AD', 5),
(10, '2024-08-03 10:59:00', 30, 1, 'AD', 9),
(13, '2024-08-10 17:59:00', 30, 1, 'AD', 13),
(21, '2024-08-04 16:59:00', 30, 3, 'AD', 7),
(7, '2024-09-07 15:59:00', 30, 4, 'AD', 5),
(10, '2024-09-10 18:59:00', 30, 1, 'AD', 9),
(11, '2024-09-11 19:59:00', 45, 3, 'AD', 10),
(13, '2024-09-13 09:59:00', 20, 1, 'AD', 12),
(22, '2024-09-22 08:59:00', 15, 1, 'AD', 15),
(25, '2024-09-25 11:59:00', 45, 1, 'AD', 14),
(4, '2024-09-04 12:59:00', 20, 1, 'AD', 4),
(2, '2024-09-02 10:59:00', 15, 3, 'AD', 3),
(9, '2024-09-09 17:59:00', 30, 1, 'AD', 7),
(17, '2024-09-17 13:59:00', 20, 1, 'AD', 18),
(7, '2024-10-01 13:59:00', 30, 1, 'AD', 13),
(11, '2024-10-02 17:59:00', 45, 3, 'AD', 10),
(13, '2024-10-04 19:59:00', 30, 1, 'AD', 11),
(15, '2024-10-05 12:59:00', 15, 1, 'AD', 3),
(19, '2024-10-08 16:59:00', 30, 1, 'AD', 5),
(21, '2024-10-10 13:59:00', 30, 3, 'AD', 9),
(23, '2024-10-11 10:59:00', 20, 1, 'AD', 12),
(24, '2024-10-12 15:59:00', 45, 1, 'AD', 14),
(10, '2024-10-23 10:59:00', 30, 1, 'AD', 1),
(22, '2024-10-30 10:59:00', 15, 1, 'AD', 15),
(7, '2024-11-01 11:59:00', 30, 1, 'AD', 5),
(4, '2024-11-02 09:59:00', 20, 1, 'AD', 4),
(10, '2024-11-03 15:59:00', 45, 1, 'AD', 6),
(15, '2024-11-03 17:59:00', 15, 1, 'AD', 3),
(21, '2024-11-06 18:59:00', 30, 3, 'AD', 9),
(22, '2024-11-30 12:59:00', 15, 1, 'AD', 15),
(24, '2024-11-14 13:59:00', 20, 1, 'AD', 18),
(11, '2024-11-04 13:59:00', 45, 3, 'AD', 10),
(19, '2024-11-05 16:59:00', 30, 1, 'AD', 1),
(13, '2024-11-13 20:59:00', 30, 1, 'AD', 13),
(7, '2024-11-01 11:59:00', 30, 1, 'AD', 5),
(4, '2024-11-02 09:59:00', 20, 1, 'AD', 4),
(10, '2024-11-03 15:59:00', 45, 1, 'AD', 6),
(15, '2024-11-03 17:59:00', 15, 1, 'AD', 3),
(21, '2024-11-06 18:59:00', 30, 3, 'AD', 9),
(22, '2024-11-30 12:59:00', 15, 1, 'AD', 15),
(24, '2024-11-14 13:59:00', 20, 1, 'AD', 18),
(11, '2024-11-04 13:59:00', 45, 3, 'AD', 10),
(19, '2024-11-05 16:59:00', 30, 1, 'AD', 1),
(13, '2024-11-13 20:59:00', 30, 1, 'AD', 13),
(7, '2025-01-01 11:59:00', 30, 1, 'AD', 5),
(10, '2025-01-02 09:59:00', 30, 1, 'AD', 9),
(11, '2025-01-02 14:59:00', 45, 3, 'AD', 10),
(13, '2025-01-13 18:59:00', 20, 1, 'AD', 12),
(21, '2025-01-03 17:59:00', 30, 3, 'AD', 7),
(22, '2025-01-26 10:59:00', 15, 1, 'AD', 15),
(24, '2025-01-06 20:59:00', 30, 1, 'AD', 11),
(4, '2025-01-07 13:59:00', 20, 1, 'AD', 4),
(19, '2025-01-03 15:59:00', 30, 1, 'AD', 1),
(2, '2025-01-05 10:59:00', 15, 3, 'AD', 3),
(13, '2025-03-14 09:59:00', 30, 1, 'AD', 1),
(14, '2025-03-14 10:59:00', 30, 1, 'AD', 5),
(7, '2025-02-10 13:59:00', 30, 1, 'AD', 7),
(10, '2025-02-11 14:59:00', 45, 1, 'AD', 10),
(11, '2025-02-12 09:59:00', 60, 3, 'AD', 8),
(19, '2025-02-13 17:59:00', 30, 1, 'AD', 9),
(21, '2025-02-14 08:59:00', 20, 3, 'AD', 12),
(23, '2025-02-15 10:59:00', 15, 1, 'AD', 3),
(24, '2025-02-28 14:59:00', 20, 1, 'AD', 18),
(25, '2025-02-26 09:59:00', 15, 1, 'AD', 15), 
(13, '2025-06-15 19:59:00', 30, 1, 'AD', 13),
(14, '2025-07-20 17:59:00', 15, 1, 'AD', 3),
(18, '2025-08-12 13:59:00', 30, 3, 'AD', 9),
(7, '2025-06-01 09:59:00', 30, 1, 'AD', 5),
(10, '2025-06-02 10:59:00', 45, 1, 'AD', 10),
(11, '2025-06-03 11:59:00', 60, 3, 'AD', 8),
(15, '2025-06-04 12:59:00', 30, 1, 'AD', 1),
(21, '2025-06-07 08:59:00', 20, 3, 'AD', 12),
(25, '2025-06-09 13:59:00', 15, 1, 'AD', 15),
(22, '2025-08-14 10:59:00', 30, 1, 'AD', 11),
(7, '2025-09-07 14:59:00', 30, 1, 'AD', 5),
(10, '2025-09-10 18:59:00', 30, 1, 'AD', 9),
(11, '2025-09-11 09:59:00', 45, 3, 'AD', 10),
(13, '2025-09-13 19:59:00', 20, 1, 'AD', 12),
(15, '2025-09-15 12:59:00', 15, 1, 'AD', 3),
(22, '2025-09-22 07:59:00', 15, 1, 'AD', 15),
(4, '2025-09-04 10:59:00', 20, 1, 'AD', 4),
(19, '2025-09-19 15:59:00', 30, 1, 'AD', 1),
(2, '2025-09-02 09:59:00', 15, 3, 'AD', 3),
(17, '2025-09-17 13:59:00', 20, 4, 'AD', 18),
(13, '2025-11-15 09:59:00', 30, 1, 'AD', 13),
(14, '2025-11-16 10:59:00', 15, 1, 'AD', 3),
(18, '2025-12-01 08:59:00', 30, 3, 'AD', 9),
(7, '2025-12-02 13:59:00', 30, 1, 'AD', 5),
(10, '2025-12-03 14:59:00', 45, 1, 'AD', 10),
(11, '2025-12-04 09:59:00', 60, 3, 'AD', 8),
(15, '2025-12-08 13:59:00', 30, 1, 'AD', 1),
(21, '2025-12-06 08:59:00', 20, 3, 'AD', 12),
(25, '2025-12-08 13:59:00', 15, 1, 'AD', 15),
(22, '2025-12-21 10:59:00', 30, 1, 'AD', 11),
(13, '2025-02-01 09:59:00', 30, 1, 'AD', 13),
(14, '2025-02-02 10:59:00', 15, 1, 'AD', 3),
(18, '2025-02-03 13:59:00', 30, 3, 'AD', 9),
(7, '2025-02-04 14:59:00', 30, 1, 'AD', 5),
(10, '2025-02-05 15:59:00', 45, 1, 'AD', 10),
(11, '2025-02-06 09:59:00', 60, 3, 'AD', 8),
(15, '2025-02-10 13:59:00', 30, 1, 'AD', 1),
(21, '2025-02-08 08:59:00', 20, 3, 'AD', 12),
(25, '2025-02-10 13:59:00', 15, 1, 'AD', 15),
(22, '2025-02-26 12:59:00', 30, 1, 'AD', 11),
(13, '2025-03-14 19:59:00', 30, 1, 'AD', 13),
(14, '2025-03-15 17:59:00', 15, 1, 'AD', 3),
(7, '2025-03-20 13:59:00', 30, 1, 'AD', 5),
(10, '2025-03-21 14:59:00', 45, 1, 'AD', 10),
(11, '2025-03-22 09:59:00', 60, 3, 'AD', 8),
(19, '2025-03-23 17:59:00', 30, 1, 'AD', 9),
(21, '2025-03-24 08:59:00', 20, 3, 'AD', 12),
(23, '2025-03-25 10:59:00', 15, 1, 'AD', 3),
(25, '2025-03-26 13:59:00', 15, 1, 'AD', 15),
(22, '2025-04-01 13:29:00', 30, 1, 'AD', 11),
(13, '2025-05-15 09:59:00', 30, 1, 'AD', 13),
(14, '2025-05-16 10:59:00', 30, 1, 'AD', 5),
(18, '2025-06-01 08:59:00', 45, 3, 'AD', 10),
(7, '2025-05-10 13:59:00', 15, 1, 'AD', 3),
(10, '2025-05-11 14:59:00', 20, 1, 'AD', 12),
(11, '2025-05-12 09:59:00', 30, 3, 'AD', 9),
(15, '2025-06-14 16:59:00', 30, 1, 'AD', 11),
(21, '2025-05-14 08:59:00', 60, 3, 'AD', 8),
(25, '2025-05-16 13:59:00', 30, 1, 'AD', 1),
(22, '2025-05-30 10:59:00', 15, 1, 'AD', 15);






