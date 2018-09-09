#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  // check for databases present...if none, create them...else, use them.
		  
		  // donations.sqlite
		  Dim donationsFile As FolderItem
		  Dim DB As New SQLiteDatabase
		  donationsFile = GetFolderItem("donations.sqlite")
		  DB.DatabaseFile = donationsFile
		  If DB.Connect Then
		    DonationTracker.show
		    Return
		  Else 
		    Dim donateF As FolderItem
		    donateF = New FolderItem("donations.sqlite")
		    Dim dF As New SQLiteDatabase
		    dF.DatabaseFile = donateF
		    If dF.CreateDatabaseFile Then
		      dF.SQLExecute("CREATE TABLE donations ( id_reference INTEGER PRIMARY KEY, firstName TEXT, lastName TEXT, email TEXT, amount REAL, timestamp TEXT );")
		      DonationTracker.show
		      Return
		    Else
		      MsgBox("Donations database not created. If problem persists, please contact developer.  Error: " + dF.ErrorMessage)
		      Quit
		    End If
		  End If
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function addRecord(anonymous As Boolean, firstName As Text, lastName As Text, email As Text, amount As Text) As Boolean
		  Dim dbFile As FolderItem
		  Dim db As New SQLiteDatabase
		  dbFile = GetFolderItem("donations.sqlite")
		  db.DatabaseFile = dbFile
		  If db.Connect Then
		    
		    Dim sqlDonation As String
		    Dim ts As Xojo.Core.Date = Xojo.Core.Date.Now
		    
		    If anonymous = True Then
		      sqlDonation = "INSERT INTO donations (amount, timestamp) VALUES ('"+ amount +"','"+ ts.ToText +"');"
		    Else
		      sqlDonation = "INSERT INTO donations (firstName, lastName, email, amount, timestamp ) VALUES ('"+ firstName +"','"+ lastName +"','"+ email +"','"+ amount +"','"+ ts.ToText +"');"
		    End If
		    
		    
		    db.SQLExecute("BEGIN TRANSACTION")
		    
		    db.SQLExecute(sqlDonation)
		    
		    If db.Error Then
		      MsgBox("Error: " + db.ErrorMessage)
		      db.Rollback
		      Return False
		    Else
		      db.Commit
		    End If
		    
		    
		    MsgBox ("Donation added successfully.")
		    
		    DonationTracker.clearFields
		    
		    Return True
		    
		  Else
		    MsgBox ("Error connecting to database.")
		    Return False
		  End If
		  
		  
		  
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function exportCSV() As Boolean
		  // set type of return
		  Dim dbFile As FolderItem
		  Dim db As New SQLiteDatabase
		  dbFile = GetFolderItem("donations.sqlite")
		  db.DatabaseFile = dbFile
		  If db.Connect Then
		    
		    Dim sqlquery As String
		    Dim r As RecordSet
		    Dim output As String
		    Dim fname, lname, email, amount, ts As String
		    Dim file As FolderItem
		    
		    sqlquery = "SELECT * FROM donations"
		    r = db.SQLSelect(sqlquery)
		    
		    If r <> Nil Then
		      Dim donationsFile As FolderItem
		      Dim fileStream As TextOutputStream
		      file = GetSaveFolderItem("", "DonationsData.txt")
		      r.MoveFirst
		      While Not r.EOF
		        fname = r.IdxField(2).StringValue
		        lname = r.IdxField(3).StringValue
		        email = r.IdxField(4).StringValue
		        amount = r.IdxField(5).StringValue
		        ts = r.IdxField(6).StringValue
		        output = output + fname +","+ lname +","+ email +","+ amount +","+ ts + Chr(34)
		        If file <> Nil Then
		          fileStream = TextOutputStream.Create(file)
		          fileStream.WriteLine(output.ToText)
		          fileStream.Close
		        End If
		        
		        r.MoveNext
		      Wend
		      
		      
		      Return True
		      
		      
		      
		      
		    Else
		      Return False
		    End If
		    
		    
		  Else
		    Return False
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function reporter(limit As String) As String
		  
		  // dim variables
		  
		  Dim donationCount As Integer
		  Dim totalAmount As Currency
		  Dim averageDonation As Currency
		  Dim sqlquery As String
		  Dim r As RecordSet
		  Dim result As String
		  
		  // set type of return
		  Dim dbFile As FolderItem
		  Dim db As New SQLiteDatabase
		  dbFile = GetFolderItem("donations.sqlite")
		  db.DatabaseFile = dbFile
		  If db.Connect Then
		    
		    
		    If limit = "all" Then
		      
		      sqlQuery = "SELECT COUNT(id_reference) FROM donations"
		      
		      r = db.SQLSelect(sqlquery)
		      If db.Error Then
		        MsgBox("Error: " + db.ErrorMessage)
		        Return "Error - exiting"
		      Else
		        If r <> Nil Then
		          
		          donationCount = Integer.FromText(r.IdxField(1).StringValue.ToText)
		          
		        End If
		      End If
		      
		      
		      sqlQuery = "SELECT SUM(amount) FROM donations"
		      
		      r = db.SQLSelect(sqlquery)
		      If db.Error Then
		        MsgBox("Error: " + db.ErrorMessage)
		        Return "Error - exiting"
		      Else
		        If r <> Nil Then
		          
		          totalAmount = Currency.FromText(r.IdxField(1).StringValue.ToText)
		          
		        End If
		      End If
		      
		      
		      averageDonation = totalAmount / donationCount
		      result = "Donation Count: "+ donationCount.ToText +", Total Donations: $"+ totalAmount.ToText +", Average Donation: $"+ averageDonation.ToText
		      Return result
		      
		    Elseif limit = "anonymous" Then
		      sqlQuery = "SELECT COUNT(id_reference) FROM donations WHERE firstName IS NULL"
		      
		      r = db.SQLSelect(sqlquery)
		      If db.Error Then
		        MsgBox("Error: " + db.ErrorMessage)
		        Return "Error - exiting"
		      Else
		        If r <> Nil Then
		          
		          donationCount = Integer.FromText(r.IdxField(1).StringValue.ToText)
		          
		        End If
		      End If
		      
		      
		      sqlQuery = "SELECT SUM(amount) FROM donations WHERE firstName IS NULL"
		      
		      r = db.SQLSelect(sqlquery)
		      If db.Error Then
		        MsgBox("Error: " + db.ErrorMessage)
		        Return "Error - exiting"
		      Else
		        If r <> Nil Then
		          
		          totalAmount = Currency.FromText(r.IdxField(1).StringValue.ToText)
		          
		        End If
		      End If
		      
		      
		      averageDonation = totalAmount / donationCount
		      result = "Donation Count: "+ donationCount.ToText +", Total Donations: $"+ totalAmount.ToText +", Average Donation: $"+ averageDonation.ToText
		      return result
		    Else
		      sqlQuery = "SELECT COUNT(id_reference) FROM donations WHERE firstName IS NOT NULL"
		      
		      r = db.SQLSelect(sqlquery)
		      If db.Error Then
		        MsgBox("Error: " + db.ErrorMessage)
		        Return "Error - exiting"
		      Else
		        If r <> Nil Then
		          
		          donationCount = Integer.FromText(r.IdxField(1).StringValue.ToText)
		          
		        End If
		      End If
		      
		      
		      sqlQuery = "SELECT SUM(amount) FROM donations WHERE firstName IS NOT NULL"
		      
		      r = db.SQLSelect(sqlquery)
		      If db.Error Then
		        MsgBox("Error: " + db.ErrorMessage)
		        Return "Error - exiting"
		      Else
		        If r <> Nil Then
		          
		          totalAmount = Currency.FromText(r.IdxField(1).StringValue.ToText)
		          
		        End If
		      End If
		      
		      
		      averageDonation = totalAmount / donationCount
		      result = "Donation Count: "+ donationCount.ToText +", Total Donations: $"+ totalAmount.ToText +", Average Donation: $"+ averageDonation.ToText
		      Return result
		    End If
		    
		  Else
		    MsgBox ("Error connecting to database.")
		    Return "Error - exiting"
		  End If
		  
		  
		  
		  
		End Function
	#tag EndMethod


	#tag Constant, Name = adminPassword, Type = Text, Dynamic = False, Default = \"donationTracker", Scope = Public
		#Tag Instance, Platform = Any, Language = Default, Definition  = \"donationTracker"
	#tag EndConstant

	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
