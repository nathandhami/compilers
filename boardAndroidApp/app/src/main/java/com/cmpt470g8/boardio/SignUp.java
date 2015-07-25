package com.cmpt470g8.boardio;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;

import java.util.ArrayList;
import java.util.concurrent.ExecutionException;


public class SignUp extends ActionBarActivity {
    public ArrayList<User> users = new ArrayList<User>();
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sign_up);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_sign_up, menu);
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

    public void createNewUser(View view){
        EditText editUserName = (EditText) findViewById(R.id.enterNewUserName);
        EditText editPassword = (EditText) findViewById(R.id.enterPassword);
        EditText editConfirmPassword = (EditText) findViewById(R.id.confirmPassword);
        EditText editEmail = (EditText) findViewById(R.id.enterEmail);

        String username = editUserName.getText().toString();
        String password = editPassword.getText().toString();
        String confirmPass = editConfirmPassword.getText().toString();
        String email = editEmail.getText().toString();

        if (username.equals("")){
            new AlertDialog.Builder(this)
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setTitle("Oops!")
                    .setMessage("Please enter a username")
                    .setPositiveButton("...Fine", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }

                    })
                    .show();
        }
        else if (password.equals("")){
            new AlertDialog.Builder(this)
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setTitle("Oops!")
                    .setMessage("Password must be longer than zero")
                    .setPositiveButton("...Fine", new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }

                    })
                    .show();
        }
        else if (!password.equals(confirmPass)){
            new AlertDialog.Builder(this)
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setTitle("Oops!")
                    .setMessage("Passwords do not match")
                    .setPositiveButton("...Fine", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }

                    })
                    .show();
        }
        else if (email.equals("")){
            new AlertDialog.Builder(this)
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setTitle("Oops!")
                    .setMessage("Please enter an email address")
                    .setPositiveButton("...Fine", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }

                    })
                    .show();
        }
        else{
            GetUsers tskget = new GetUsers();
            try{
                users = tskget.execute().get();
            } catch(InterruptedException e){
                e.printStackTrace();
            } catch (ExecutionException e) {
                e.printStackTrace();
            }
            boolean taken = false;
            for (int i=0; i<users.size(); ++i){
                if (users.get(i).name.equals(username)){
                    new AlertDialog.Builder(this)
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .setTitle("Oops!")
                            .setMessage("That user name is already taken")
                            .setPositiveButton("...Fine", new DialogInterface.OnClickListener()
                            {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {

                                }

                            })
                            .show();
                    taken = true;
                }
            }

            if (!taken) {
                User newUser = new User();
                newUser.name = username;
                newUser.password = password;
                newUser.email = email;
                SaveUser tsk = new SaveUser();
                tsk.execute(newUser);
                new AlertDialog.Builder(this)
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .setTitle("Yay!")
                        .setMessage("You have created an account!")
                        .setPositiveButton("Cool!", new DialogInterface.OnClickListener()
                        {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                finish();
                            }

                        })
                        .show();
            }
        }
    }
}
