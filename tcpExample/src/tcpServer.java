/** **************************************************************
 * tcpServer.java
 *
 * usage : java tcpServer.
 * default port is 5050.
 * connection to be closed by client.
 * this server handles only 1 connection; it is single threaded.
 * *
 *
 * Copyright (c) 2002-2007 Advanced Applications Total Applications Works.
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
 **************************************************************** */

import java.io.*;
import java.net.*;
import java.awt.*;
import java.awt.event.*;
import javax.swing.*;
import java.util.*;

/** **************************************************************
 *  The purpose of the tcpServer class is to create a server that
 *  1- Creates a server main frame
 *  2- Establishes a server socker
 *  3- Accepts clients in a multithreaded environment
 ****************************************************************/
public class tcpServer extends JFrame implements  ActionListener {
    private int port = 5050 , trdCnt = 0 ;
    private ServerSocket server_socket;
    private BufferedReader input;
    private PrintWriter output;
    private Container c ;
    private JTextArea display ;
    private JButton cancel , send, exit;
    private JPanel buttonPanel ;
    private boolean debug = false , loopCTL = true , loopCTL2 = true ;
    private Thread thrd[] ;
    private GregorianCalendar cal;


   /** **************************************************************
    * This is the tcpServer constructor
    ****************************************************************/
    public  tcpServer() {
       super ( "Multithreaded Server" ) ;

       setupThreads() ;

       setup() ;

       ServerRun() ;
    }

    /**  **************************************************************
     * The setThreadcount() method resets the thread count.
     ****************************************************************/
    public  void setThreadcount( int a ) {
       trdCnt = a ;
    }
    /**  **************************************************************
     * The setUp() method does the intialization for the application.
     * The logic is
     *  1- Get the content pane
     *  2- Define a Gregorian Calendar to enable us to get the current time.
     *  3- Define an exit push button.
     *  4- Define a panel to contain the exit push button.
     *  5- Add the exit push button to the button panel.
     *  6- Using the BorderLayout manager add the buttonPanel to bottom of
     *     the content pane.
     *  7- Add an ActionListener to the exit push button.
     *  8- Define a text area to display mesaages.
     *  9- Add the text area to the center of the content pane.
     * 10- Set the size of the main frame.
     * 11- Set the initial location of the main frame on the terminal.
     * 12- Make the main frame visible on the main frame.
     *
     ****************************************************************/
    public  void setup() {
      c = getContentPane();


      cal = new GregorianCalendar()  ;

      exit = new JButton( "Exit" );
      exit.setBackground( Color.red ) ;
      exit.setForeground( Color.white ) ;
      buttonPanel = new JPanel() ;
      buttonPanel.add( exit ) ;
      c.add( buttonPanel , BorderLayout.SOUTH) ;

      exit.addActionListener( this );

      display = new JTextArea();
      c.add( new JScrollPane( display ),
             BorderLayout.CENTER );

      setSize( 400, 400 );
      setLocation( 10, 20 ) ;
      show();
    }

   /**  ******************************************************************
    * The setupThreads() method
    *********************************************************************/
    public void setupThreads() {

      thrd = new Thread[ 15 ] ;
    }

   /**  ******************************************************************
    * The ServerRun() method in the server reads and writes data to the
    * client. the logic for the ServerRun() method is
    *  1- Create a ServerSocket object
    *  2- Create messages and display them in the text area.
    *  3- Loop while waiting for Client connections.
    *  4- Call ServerSocket accept() method and listen.
    *  5- Create an InputStreamReader based on the socket.getInputStream() object
    *  6- Create a BufferedReader based on the  InputStreamReader object
    *  7- Create a new MyThread object
    *  8- Start the new MyThread object
    *********************************************************************/
    public void ServerRun() {
       try {

          server_socket = new ServerSocket( 5050, 100,
                                  InetAddress.getByName("127.0.0.1"));
          display.setText("This multithreded example is presented by\nRonald S. Holland\nat Total Application Works\n\n" ) ;
          display.append("Server waiting for client on port " +
			       server_socket.getLocalPort() + "\n");

            // server in in infinite loop while listening for messages
          while( loopCTL ) {
             Socket socket = server_socket.accept();
             sysPrint("New connection accepted " +
                        socket.getInetAddress() +
                        ":" + socket.getPort());

             input = new BufferedReader( new InputStreamReader(socket.getInputStream() ) );

                   // Construct handler to process the Client request message.
            try {
               MyThread request =
                              new MyThread( this , socket , trdCnt );
               thrd[ trdCnt ]  = request ;

                  // Start the thread.
               thrd[ trdCnt ].start() ;
               trdCnt++ ;
            }
            catch(Exception e) {
	       sysPrint( "" + e);
            }
         }   // End of while loop

       }
       catch (IOException e) {
          display.append("\n" + e);
       }
    }

   /**  ******************************************************************
    * This method responds to the exit button
    *  being pressed on the tcpServer frame.
     **********************************************************************/
   public void actionPerformed( ActionEvent e )    {
      if ( e.getSource() == exit )
         sysExit( 0 ) ;
   }

   /**  ****************************************************************
    * This method closes the socket connect to the server.
     *******************************************************************/
   private void closeConnection() {
      sysPrint("There are " + trdCnt + " currently threads running." ) ;
      for( int ii = 0 ; ii < trdCnt ; ii ++ ) {
         thrd[ ii ] = null ;
      }

      try {
         server_socket.close();
      }
      catch (IOException e) {
         display.append("\n" + e);
      }
   }

   /** ***********************************************************
    * The sysExit() method is called in response to a close
    * application event.
    ************************************************************* */
   public void sysExit( int ext ) {
      loopCTL  = false ;
      loopCTL2 = false ;
      closeConnection() ;
      System.exit( ext ) ;
   }

   /** ***********************************************************
    * The sysPrint method prints out debugging messages.
    ************************************************************ */
   public void sysPrint( String str ) {
      if( debug ) {
         System.out.println("" + str ) ;
      }
   }

   /** ***********************************************************
    * The main() is called by Java when the tcpServer program is
    *  loaded.
    ************************************************************ */
    public static void main(String args[]) {
       final tcpServer server = new tcpServer() ;
       server.addWindowListener(
         new WindowAdapter() {
            public void windowClosing( WindowEvent e )  {
               server.sysExit( 0 );
            }
         } // End of WindowAdapter()
      );  // End of addWindowListener
    }

   /** ***********************************************************
    *  The purpose of the MyThread class is to create a thread of
    *  execution to respond to client requests.  A thread is a
    *  thread of execution in a program. The Java Virtual Machine
    *  allows an application to have multiple threads of execution
    *  running concurrently.
    **************************************************************/
   public class MyThread extends Thread {
      Socket socket;
      InputStream input2;
      PrintWriter output2;
      private BufferedReader br ;
      private PrintWriter outp ;
      private int trdCnt ;
      private tcpServer tcpS ;

      /** *********************************************************
       * The purpose of the MyThread() constructor is to used the
       * passed parameters to initialize MyThread class level
       * variables.
       **************************************************************/
      public MyThread( tcpServer tps , Socket socket , int trd_Cnt ) throws Exception {
         trdCnt =  trd_Cnt ;
         tcpS = tps ;
         this.socket  = socket;
         outp         = new PrintWriter(socket.getOutputStream(),true);
         this.input2  = socket.getInputStream();
         this.output2 = new PrintWriter(socket.getOutputStream(),true);
         this.br      =  new BufferedReader(
                       new InputStreamReader( socket.getInputStream() ) ) ;
      }

      /** *********************************************************
       * The run() method responds to the client's request.
       **************************************************************/
      public void run() {
         sysPrint( "Thread run() 1: running Thread" + (trdCnt+1) ) ;
         display.append("\nThread run() 1: running Thread" + (trdCnt+1) );

         try {

            while( loopCTL2 ) {
               String message = br.readLine();
               String ttle = " From Server on Thread" ;
               String anmsge = " and message is " ;
               String tme = "\nTime " + cal.get( cal.HOUR )  + ":" +  cal.get( cal.MINUTE ) +
                   ":" +  cal.get( cal.SECOND ) ;
               sysPrint( "processRequest() 2:" + message ) ;

               display.append("\nThread" +  (trdCnt+1) + " "  + message ) ;
               output2.println( tme + ttle + (trdCnt+1) + anmsge + message );
               if (message.toUpperCase().equals( "QUIT" )) {
                  loopCTL2 = true;
               }
            }
         }
         catch(Exception e) {
            System.out.println(e);
         }
      }

   }
}
