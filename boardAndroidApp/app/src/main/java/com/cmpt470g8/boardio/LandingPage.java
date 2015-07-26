package com.cmpt470g8.boardio;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.concurrent.ExecutionException;


public class LandingPage extends ActionBarActivity
        implements NavigationDrawerFragment.NavigationDrawerCallbacks {

    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment mNavigationDrawerFragment;
    private ListView mDrawerList;
    private ArrayAdapter<String> mAdapter;
    public final static String EXTRA_MESSAGE = "com.cmpt470g8.boardio.message";
    public int loggedIn = 0;
    ListView list;
    ArrayList<String> listItems;
    ArrayAdapter<String> adapter;
    ArrayList<Event> events = new ArrayList<Event>();
    public String currentUser ="";

    /**
     * Used to store the last screen title. For use in {@link #restoreActionBar()}.
     */
    private CharSequence mTitle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_landing_page);

        mNavigationDrawerFragment = (NavigationDrawerFragment)
                getSupportFragmentManager().findFragmentById(R.id.navigation_drawer);
        mTitle = getTitle();

        // Set up the drawer.
        mNavigationDrawerFragment.setUp(R.id.navigation_drawer,(DrawerLayout) findViewById(R.id.drawer_layout));
        mDrawerList = (ListView) findViewById(R.id.navList);
        list = (ListView)findViewById(R.id.activityList);
        listItems = new ArrayList<String>();
        Intent intent = getIntent();
        //Bundle bundle = intent.getBundleExtra(EXTRA_MESSAGE);
        //loggedIn = bundle.getInt("loggedIn");
        //if (loggedIn == 1)
        //    currentUser = bundle.getString("username");
        loggedIn = intent.getIntExtra(EXTRA_MESSAGE,0);

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
                    for (int i = 0; i < body.length(); ++i) {
                        if (body.charAt(i) == ',') {
                            comma = 1;
                            continue;
                        }
                        if (comma == 0) {
                            username += body.charAt(i);
                        } else
                            password += body.charAt(i);
                        currentUser = username;
                    }
                } catch (Exception exc) {
                    new AlertDialog.Builder(this)
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .setTitle("Error")
                            .setMessage("Logged in user could not be read")
                            .setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {
                                }
                            })
                            .show();
                }
            }
        }
        adapter = new ArrayAdapter<String>(getApplicationContext(), android.R.layout.simple_list_item_1, listItems);
        list.setAdapter(adapter);
        loadActivities(loggedIn);

        list.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                Intent intent = new Intent(LandingPage.this, Details.class);
                Event selected = events.get(position);
                Bundle bundle = new Bundle();
                bundle.putString("name", selected.name);
                bundle.putString("description", selected.description);
                bundle.putString("location", selected.location);
                bundle.putString("date", selected.date);
                bundle.putString("latitude", selected.latitude);
                bundle.putString("longitude", selected.longitude);
                intent.putExtra(EXTRA_MESSAGE, bundle);
                startActivity(intent);
            }
        });

    }

    @Override
    public void onNavigationDrawerItemSelected(int position) {
        // update the main content by replacing fragments
        FragmentManager fragmentManager = getSupportFragmentManager();
        fragmentManager.beginTransaction()
                .replace(R.id.container, PlaceholderFragment.newInstance(position + 1))
                .commit();
    }

    @Override
    public void onSaveInstanceState(Bundle savedInstanceState) {
        savedInstanceState.putInt("loggedIn", loggedIn);
        savedInstanceState.putString("username", currentUser);
        super.onSaveInstanceState(savedInstanceState);
    }

    @Override
    public void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        loggedIn = savedInstanceState.getInt("loggedIn");
        currentUser = savedInstanceState.getString("username");
        listItems.clear();
        loadActivities(loggedIn);
    }

    @Override
    public void onBackPressed() {
        new AlertDialog.Builder(this)
                .setIcon(android.R.drawable.ic_dialog_alert)
                .setTitle("Exit")
                .setMessage("Are you sure you want to quit?\nYou will be logged out.")
                .setPositiveButton("Quit", new DialogInterface.OnClickListener()
                {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        String root = Environment.getExternalStorageDirectory().toString();
                        File myDir = new File(root + "/board.io");
                        File file = new File(myDir, "session.txt");
                        boolean deleted = file.delete();
                        if (deleted){
                            finish();
                        }
                        finish();
                    }
                })
                .setNegativeButton("No", null)
                .show();
    }

        public void onSectionAttached(int number) {
        Intent intent;
        int message;
        String user;
        switch (number) {
            case 1:
                intent = new Intent(this, MapsActivity.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
            case 2:
                if (loggedIn == 1) {
                    intent = new Intent(this, CreateEvent.class);
                    intent.putExtra(EXTRA_MESSAGE, currentUser);
                    startActivityForResult(intent, 1);
                }else{
                    new AlertDialog.Builder(this)
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .setTitle("Oops!")
                            .setMessage("You must be logged in to create an event.")
                            .setPositiveButton("Ok", new DialogInterface.OnClickListener()
                            {
                                @Override
                                public void onClick(DialogInterface dialog, int which) {

                                }

                            })
                            .show();
                }
                break;
            case 3:
                intent = new Intent(this, Profile.class);
                intent.putExtra(EXTRA_MESSAGE, currentUser);
                startActivity(intent);
                break;
            case 4:
                intent = new Intent(this, Buddies.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
            case 5:
                intent = new Intent(this, SettingsActivity.class);
                message = 0;
                intent.putExtra(EXTRA_MESSAGE, message);
                startActivity(intent);
                break;
        }
    }

    public void restoreActionBar() {
        ActionBar actionBar = getSupportActionBar();
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setTitle(mTitle);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        if (!mNavigationDrawerFragment.isDrawerOpen()) {
            // Only show items in the action bar relevant to this screen
            // if the drawer is not showing. Otherwise, let the drawer
            // decide what to show in the action bar.
            getMenuInflater().inflate(R.menu.landing_page, menu);
            restoreActionBar();
            return true;
        }
        super.onCreateOptionsMenu(menu);
        if (loggedIn == 1)
            menu.add(0,0, 0, "Log Out");
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
            Intent intent = new Intent(this, SettingsActivity.class);
            int message = 0;
            intent.putExtra(EXTRA_MESSAGE, message);
            startActivity(intent);
        }

        if (id == R.id.action_logout) {
            String root = Environment.getExternalStorageDirectory().toString();
            File myDir = new File(root + "/board.io");
            File file = new File(myDir, "session.txt");
            boolean deleted = file.delete();
            if (deleted){
                finish();
            }
        }

        return super.onOptionsItemSelected(item);
    }


    /**
     * A placeholder fragment containing a simple view.
     */
    public static class PlaceholderFragment extends Fragment {
        /**
         * The fragment argument representing the section number for this
         * fragment.
         */
        private static final String ARG_SECTION_NUMBER = "section_number";

        /**
         * Returns a new instance of this fragment for the given section
         * number.
         */
        public static PlaceholderFragment newInstance(int sectionNumber) {
            PlaceholderFragment fragment = new PlaceholderFragment();
            Bundle args = new Bundle();
            args.putInt(ARG_SECTION_NUMBER, sectionNumber);
            fragment.setArguments(args);
            return fragment;
        }

        public PlaceholderFragment() {
        }

        @Override
        public View onCreateView(LayoutInflater inflater, ViewGroup container,
                                 Bundle savedInstanceState) {
            View rootView = inflater.inflate(R.layout.fragment_landing_page, container, false);
            return rootView;
        }

        @Override
        public void onAttach(Activity activity) {
            super.onAttach(activity);
            ((LandingPage) activity).onSectionAttached(
                    getArguments().getInt(ARG_SECTION_NUMBER));
        }
    }

    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (resultCode == RESULT_OK) {
            listItems.clear();
            loadActivities(loggedIn);
        }
    }

        public void loadActivities(int loggedIn){
        GetEvents tsk = new GetEvents();
        try{
            events = tsk.execute().get();
        } catch(InterruptedException e){
            e.printStackTrace();
        } catch (ExecutionException e) {
            e.printStackTrace();
        }

        for (int i=0; i<events.size(); ++i){
            listItems.add(events.get(i).name);
        }

        adapter.notifyDataSetChanged();
    }

    public void create(View view)throws UnknownHostException{
        if (loggedIn == 1) {
            Intent intent = new Intent(this, CreateEvent.class);
            intent.putExtra(EXTRA_MESSAGE, currentUser);
            startActivityForResult(intent,1);
        }else{
            new AlertDialog.Builder(this)
                    .setIcon(android.R.drawable.ic_dialog_alert)
                    .setTitle("Oops!")
                    .setMessage("You must be logged in to create an event.")
                    .setPositiveButton("Ok", new DialogInterface.OnClickListener()
                    {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {

                        }

                    })
                    .show();
        }
    }
}
