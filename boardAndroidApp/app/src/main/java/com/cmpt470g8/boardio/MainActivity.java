package com.cmpt470g8.boardio;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.EditText;


public class MainActivity extends ActionBarActivity {
    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
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
        Intent intent = new Intent(this,LandingPage.class);
        EditText username = (EditText) findViewById(R.id.usernameBox);
        String message = username.getText().toString();
        intent.putExtra(EXTRA_MESSAGE, message);
        startActivity(intent);
    }

    public void skip(View view){
        Intent intent = new Intent(this,LandingPage.class);
        String message = "Guest";
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
