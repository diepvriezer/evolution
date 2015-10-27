/*************************************************************
 * tcpClient.java
 *
 * Version 1.1
 *
 * Set up a client that will receive
 *    - a connection from a server
 *      - requests for services
 *        - Send
 *
 *    - process server responses to string(s) sent back to the client
 *    - and close the connection when the Client is finished.
 *
 *
 * Copyright (c) 2002-2006 Advanced Applications Total Applications Works.
 * (AATAW)  All Rights Reserved.
 *
 * AATAW grants you ("Licensee") a non-exclusive, royalty free, license to use,
 * modify and redistribute this software in source and binary code form,
 * provided that i) this copyright notice and license appear on all copies of
 * the software; and ii) Licensee does not utilize the software in a manner
 * which is disparaging to AATAW.
 *
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY
 * IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
 * NON-INFRINGEMENT, ARE HEREBY EXCLUDED. AATAW AND ITS LICENSORS SHALL NOT BE
 * LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING
 * OR DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL AATAW OR ITS
 * LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT,
 * INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER
 * CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF
 * OR INABILITY TO USE SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGES.
 *
 * This software is not designed or intended for use in on-line control of
 * aircraft, air traffic, aircraft navigation or aircraft communications; or in
 * the design, construction, operation or maintenance of any nuclear
 * facility. Licensee represents and warrants that it will not use or
 * redistribute the Software for such purposes or for commercial purposes.
 *
 * Changelog:
 * default port is 5050
 *************************************************************/

import javax.swing.*;
import java.awt.*;
import java.io.*;
import java.awt.event.*;
import java.net.*;


 /** ***********************************************************
  * The tcpClient class creates an object for the Client frame.
 * Set up a client that will receive
 *    - a connection from a server
 *      - requests for services
 *        - Send
 *
 *    - process server responses to string(s) sent back to the client
 *    - and close the connection when the Client is finished.
 *
  **************************************************************/
public class tcpClient extends JFrame implements  ActionListener {
   private int port = 5050;
   private String server = "localhost";
   private Socket socket = null;
   private BufferedReader input;
   private PrintWriter output;
   private int ERROR = 1;
   private Container c ;
   private JTextArea display ;
   private JButton clear , send, exit;
   private JPanel buttonPanel, textPanel ;
   private JTextField enterBox;
   private JLabel enterLabel;

   /** ***********************************************************
    * The tcpClient constructor initializes the tcpClient object.
    ************************************************************ */
   public tcpClient() {
      super( "Client" ) ;

      setUp() ;

      connect() ;

      RunClient() ;

      closeConnection() ;
   }

   /** **************************************************************
    * The setUp() method does the intialization for the application.
    * The setUp() method
    * 1- Creates JButtons
    * 2- Creates JPanels
    * 3- Creates JLabels
    * 4- Adds Action Listeners to the JButtons
    * 5- Sets the size for the JFrame
    * 6- Sets the location for the JFrame
    * 7- Makes the JFrame visible
    *************************************************************** */
   public void setUp() {

      c = getContentPane();

      /** Create JButtons */
      send = new JButton( "Send" );
      clear = new JButton( "Clear Message" );
      exit = new JButton( "Exit" );

      /** Set up the Background Color */
      send.setBackground( Color.blue ) ;
      exit.setBackground( Color.red ) ;
      clear.setBackground( Color.white ) ;

      /** Set up the Foreground Color */
      send.setForeground( Color.white ) ;
      exit.setForeground( Color.white ) ;
      buttonPanel = new JPanel() ;

      /** Add the JButtons to the buttonPanel */
      buttonPanel.add( send ) ;
      buttonPanel.add( clear ) ;
      buttonPanel.add( exit ) ;
      c.add( buttonPanel , BorderLayout.SOUTH) ;

      /** Create JLabels */
      enterLabel = new JLabel("Enter message below and then press send or clear." ) ;
      enterLabel.setFont(new Font( "Serif", Font.BOLD, 14) );
      enterLabel.setForeground( Color.black );
      enterBox = new JTextField( 100 );
      enterBox.setEditable( true );

      /** Create JPanel */
      textPanel = new JPanel() ;

      /** Set up the layout manager for the testPanel */
      textPanel.setLayout( new GridLayout( 2, 1 ) );
      textPanel.add( enterLabel ) ;
      textPanel.add( enterBox ) ;
      c.add( textPanel , BorderLayout.NORTH) ;


      /** Add an Action Listener for the send, exit and clear JButtons */
      send.addActionListener( this );
      exit.addActionListener( this );
      clear.addActionListener( this );

      /** Create JTextArea */
      display = new JTextArea();

      /** Create JScrollPane for the main area of the JFrame  */
      c.add( new JScrollPane( display ),
             BorderLayout.CENTER );

      addWindowListener( new WindowHandler( this ) );
      setSize( 400, 400 );
      setLocation( 450, 20 ) ;
      show();

   }

   /** ***********************************************************
    * The connect() method does the intialization of the client
    * socket on localhost and port 5050
    **************************************************************/
   public void connect() {
      // connect to server
      try {
         socket = new Socket(server, port);
         display.setText("Connected with server " +
              socket.getInetAddress() +
              ":" + socket.getPort());
      }
      catch (UnknownHostException e) {
         display.setText("" + e);
         System.exit(ERROR);
      }
      catch (IOException e) {
         display.setText("\n" + e);
         System.exit(ERROR);
      }
   }

   /** ***********************************************************
    * The sendData() method in the client sends data to the server
    ************************************************************ */
   public void sendData(String str) {
      output.println( str + " from Client" + socket.getLocalPort() );
   }


   /** ***********************************************************
    * The RunClient() method in the client reads and writes data
    * to the server.
    **************************************************************/
   public void RunClient() {
      try {
         input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
         output = new PrintWriter(socket.getOutputStream(),true);

         while(true) {
            String message = input.readLine();
            /**
             * stop if input line equals "QUIT"
             */
            if (message.toUpperCase().equals( "FROM SERVER==> QUIT" ) )
               break;
            display.append( "\n" +  message ) ;
         }
      }
      catch (IOException e) {
         display.append("\n" + e);
      }

   }

   /** *******************************************************
    * This method responds to the send, clear or exit button
    *  being pressed on the tcpClient frame.
    ******************************************************** */
   public void actionPerformed( ActionEvent e )    {
      if ( e.getSource() == clear ) {
         enterBox.setText( "" );
      }
      // get user input and send it to server
      else if ( e.getSource() == send ) {
         sendData( enterBox.getText() );
         display.append( "\n" +  enterBox.getText() ) ;
      }
      else if ( e.getSource() == exit ) {
         closeConnection() ;
      }
   }

   /** *****************************************************
    * This method closes the socket connect to the server.
    ********************************************************/
   public void closeConnection() {
      sendData( "QUIT" ) ;
      try {
         socket.close();
         input.close();
         output.close();
      }
      catch (IOException e) {
         display.append("\n" + e);
      }

      setVisible( false );
      System.exit( 0 );
   }

   /** *******************************************************
    * This method is the main entry point called by the JVM.
    ******************************************************** */
   public static void main(String[] args) {
      final tcpClient client = new tcpClient() ;

      client.addWindowListener(
         new WindowAdapter() {
            public void windowClosing( WindowEvent e )
            {
               client.closeConnection() ;
            }
         }
      );
   }

   /** *******************************************************
    * This method closes the socket connect to the server when
    * the application window is closed.
    ***********************************************************/
   public class WindowHandler extends WindowAdapter {
      tcpClient tcpC;

      public WindowHandler( tcpClient t ) { tcpC = t; }

      public void windowClosing( WindowEvent e ) { tcpC.closeConnection(); }
   }

}