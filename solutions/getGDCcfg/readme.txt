
Simple Summary:

1.Get the remote file name
2.Copy file from client to server
3.Load the xml file into memory.
4.Get the root node of the xml file
5.Find the nodes you want
6.Loop foreach node in the list
7.Get node in loop to process
8.Populate the array in the loop
9.Display the Array


Summary with hints:

1.Get the remote file name  ( winopenfile )
2.Copy file from client to server ( fgl_getfile )
3.Load the xml file into memory. ( om.domDocument.createFromXMLFile )
4.Get the root node of the xml file( getDocumentElement )
5.Find the nodes you want( selectByTagName )
6.Loop foreach node in the list
7.Get node in loop to process (om.nodelist.item)
8.Populate the array in the loop (om.node.getAttribute)
9.Display the Array (DISPLAY ARRAY)










