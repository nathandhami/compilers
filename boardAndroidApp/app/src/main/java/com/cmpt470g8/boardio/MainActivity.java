package com.cmpt470g8.boardio;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.concurrent.ExecutionException;


public class MainActivity extends ActionBarActivity {
    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    public ArrayList<User> users = new ArrayList<User>();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        String root = Environment.getExternalStorageDirectory().toString();
        File myDir = new File(root + "/board.io");
        if (myDir.exists()) {
            File file = new File(myDir, "session.txt");
            if (file.exists()) {
                //read file and login
                try {
                    StringBuilder text = new StringBuilder();
                    BufferedReader br = new BufferedReader(new FileReader(file));
                    String line;
                    int lineNum = 0;
                    while ((line = br.readLine()) != null) {
                        text.append(line);
                        text.append('\n');
                        ++lineNum;
                    }
                    br.close();
                    String body = text.toString();
                    String username = "";
                    String password = "";
                    int comma = 0;
                    for (int i=0; i<body.length(); ++i){
                          if (body.charAt(i) == ','){
                              comma = 1;
                              continue;
                          }
                        if (comma == 0){
                            username += body.charAt(i);
                        }else
                            password += body.charAt(i);
                    }
                    Intent intent = new Intent(this, LandingPage.class);
                    Bundle bundle = new Bundle();
                    bundle.putString("username",username);
                    bundle.putInt("loggedIn", 1);
                    int message = 1;
                    intent.putExtra(EXTRA_MESSAGE, message);
                    startActivity(intent);

                }catch(Exception exc){
                    new AlertDialog.Builder(this)
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .setTitle("Error")
                            .setMessage("Login session could not be created.")
                            .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                }
                            })
                            .show();
                }

            }
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    public void login(View view){
        EditText username = (EditText) findViewById(R.id.usernameBox);
        String user = username.getText().toString();
        EditText password = (EditText) findViewById(R.id.passwordBox);
        String pass = password.getText().toString();
        GetUsers tsk = new GetUsers();
        try{
            users = tsk.execute().get();
        } catch(InterruptedException e){
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }
        int loggedIn = 0;

        for (int i=0; i<users.size(); ++i){
            if (user.equals(users.get(i).name) && pass.equals(users.get(i).password)){
                loggedIn = 1;
                break;
            }
        }

        if (loggedIn == 1) {
            username.setText("");
            password.setText("");
            String root = Environment.getExternalStorageDirectory().toString();
            File myDir = new File(root + "/board.io");
            if (!myDir.exists())
                myDir.mkdirs();
            File file = new File(myDir, "session.txt");
            String body = user + "," + pass;
            if (isExternalStorageWritable())
            {
                try{
                    if (!file.exists())
                        file.createNewFile();

                    FileOutputStream saveFile = new FileOutputStream(file);
                    saveFile.write(body.getBytes());
                    saveFile.close();
                }catch(Exception exc){
                    new AlertDialog.Builder(this)
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .setTitle("Error")
                            .setMessage("Login session could not be created.")
                            .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                }
                            })
                            .show();
                }
            }

            Intent intent = new Intent(this, LandingPage.class);
            Bundle bundle = new Bundle();
            bundle.putString("username",user.toString());
            bundle.putInt("loggedIn", 1);
            int message = 1;
            intent.putExtra(EXTRA_MESSAGE, message);
            startActivity(intent);
        }else{
            new AlertDialog.Builder(this)
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setTitle("Oops!")
                    .setMessage("Username or password is incorrect.")
                    .setPositiveButton("Ok", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }

                    })
                    .show();
        }
    }

    public boolean isExternalStorageWritable(){
        String state = Environment.getExternalStorageState();
        return Environment.MEDIA_MOUNTED.equals(state);
    }

    public void skip(View view){
        Intent intent = new Intent(this,LandingPage.class);
        Bundle bundle = new Bundle();
        bundle.putInt("loggedIn", 0);
        int message = 0;
        intent.putExtra(EXTRA_MESSAGE, message);
        startActivity(intent);
    }

    public void signUp(View view){
        Intent intent = new Intent(this, SignUp.class);
        int message = 0;
        intent.putExtra(EXTRA_MESSAGE, message);
        startActivity(intent);
    }
}
