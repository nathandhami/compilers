package com.cmpt470g8.boardio;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.ArrayList;
import java.util.concurrent.ExecutionException;


public class Profile extends ActionBarActivity  {
    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    ListView listC;
    ListView listA;
    ArrayList<String> listCreated;
    ArrayList<String> listAttending;
    ArrayAdapter<String> cAdapter;
    ArrayAdapter<String> aAdapter;
    ArrayList<User> users;
    public int i=0;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);
        Intent intent = getIntent();
        String currentUser = intent.getStringExtra(EXTRA_MESSAGE);
        if (currentUser.length() == 0) {
            fillJoke();
            return;
        }

        GetUsers tsk = new GetUsers();
        try{
            users = tsk.execute().get();
        } catch(InterruptedException e){
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }

        for (i=0; i<users.size(); ++i){
            if (users.get(i).name.equals(currentUser))
                break;
        }

        TextView userName = (TextView) findViewById(R.id.lblUserName);
        TextView email = (TextView) findViewById(R.id.lblEmail);
        userName.setText(users.get(i).name);
        email.setText(users.get(i).email);
        listC = (ListView) findViewById(R.id.listCreatedEvents);
        listA = (ListView) findViewById(R.id.listAttending);
        listCreated = new ArrayList<String>();
        listAttending = new ArrayList<String>();
        cAdapter = new ArrayAdapter<String>(getApplicationContext(), android.R.layout.simple_list_item_1, listCreated);
        aAdapter = new ArrayAdapter<String>(getApplicationContext(), android.R.layout.simple_list_item_1, listAttending);
        listC.setAdapter(cAdapter);
        listA.setAdapter(aAdapter);
        getCreated();
        getAttending();
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_profile, menu);
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

    public void getCreated(){
        listCreated.add("Created 1");
        cAdapter.notifyDataSetChanged();
    }

    public void getAttending() {
        listAttending.add("Attending 1");
        aAdapter.notifyDataSetChanged();
    }

    public void fillJoke(){
        TextView userName = (TextView) findViewById(R.id.lblUserName);
        TextView email = (TextView) findViewById(R.id.lblEmail);
        userName.setText("You don't have a user name... log in!");
        email.setText("All you email are belong to US!");
    }
}
