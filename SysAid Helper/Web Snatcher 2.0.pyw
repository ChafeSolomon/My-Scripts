#Notes
''' Author Chafe Solomon
 Gui is to open SysAid tickets faster and direct

 Additional notes..
 Main will direct you to the main list of tickets that are availible.
 Knowledge will direct you to the knowledgebase articles
 New will create a new ticket. 
'''

import os
import webbrowser
from tkinter import *
from tkinter import ttk


#Query function
def OpenSysAid(*args):

    try:
        
        ticketnumber = TicketNumber.get().lower()

        if ticketnumber == "main":
            webbrowser.open('https://ennisflint.sysaidit.com/HelpDesk.jsp?fromId=List')
            root.quit()
        
        elif ticketnumber =='new':
            webbrowser.open('https://ennisflint.sysaidit.com/SREdit.jsp?id=0&fromId=List&SR_Type=1&templateID=7643')
            root.quit()

        
        elif ticketnumber =='knowledge':
            webbrowser.open('https://ennisflint.sysaidit.com/KBFAQTree.jsp')
            root.quit()

        elif ticketnumber.isdigit():
            webbrowser.open(f'https://ennisflint.sysaidit.com/SREdit.jsp?QuickAcess&id={ticketnumber}')
            root.quit()
            
        else:
            pass


    except ValueError:
        pass

    

root = Tk()
root.title("SysAid Web Assistant")
root.wm_iconbitmap("C:\\Users\csolomon\Documents\Project\Python Practice\SysAid Helper\EF.ico")
#Size of APP
mainframe = ttk.Frame(root, padding="5 5 27 5")
mainframe.grid(column=0, row=0, sticky=(N, W, E, S))
root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)

TicketNumber = StringVar()

#Ticket Number
TicketNumber_entry = ttk.Entry(mainframe, width=25, textvariable=TicketNumber)
TicketNumber_entry.grid(column=2, row=1, sticky=(W, E))

#GO
ttk.Button(mainframe, text="Load Ticket", command=OpenSysAid).grid(column=5, row=1, sticky=W)

for child in mainframe.winfo_children(): child.grid_configure(padx=5, pady=5)

TicketNumber_entry.focus()
root.bind('<Return>', OpenSysAid)

root.mainloop()





